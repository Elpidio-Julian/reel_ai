import 'dart:io';
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../services/video_service.dart';

part 'video_upload_provider.g.dart';
part 'video_upload_provider.freezed.dart';

@freezed
class VideoUploadState with _$VideoUploadState {
  const factory VideoUploadState({
    @Default(false) bool isLoading,
    String? error,
    File? selectedVideo,
    String? description,
    @Default(false) bool isUploading,
    double? uploadProgress,
  }) = _VideoUploadState;
}

@riverpod
VideoService videoService(Ref ref) {
  return VideoService();
}

@riverpod
class VideoPlayerControllerNotifier extends _$VideoPlayerControllerNotifier {
  VideoPlayerController? _controller;

  @override
  FutureOr<VideoPlayerController?> build() async {
    ref.onDispose(() async {
      await _controller?.pause();
      await _controller?.dispose();
      _controller = null;
    });
    return null;
  }

  Future<void> initializeController(File videoFile) async {
    state = const AsyncLoading();
    
    try {
      // Dispose old controller if exists
      if (_controller != null) {
        await _controller!.pause();
        await _controller!.dispose();
        _controller = null;
      }

      // Create and initialize new controller
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      _controller = controller;
      
      // Update state before playing
      state = AsyncData(controller);
      
      // Start playing after state is updated
      await controller.play();
    } catch (e) {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> disposeController() async {
    state = const AsyncLoading();
    if (_controller != null) {
      await _controller!.pause();
      await _controller!.dispose();
      _controller = null;
    }
    state = const AsyncData(null);
  }
}

@riverpod
class VideoUploadController extends _$VideoUploadController {
  @override
  VideoUploadState build() => const VideoUploadState();

  Future<void> pickVideo() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final video = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );
      
      if (video != null) {
        final videoFile = File(video.path);
        state = state.copyWith(
          selectedVideo: videoFile,
          isLoading: false,
        );
        // Initialize video player after state update
        await ref.read(videoPlayerControllerNotifierProvider.notifier)
          .initializeController(videoFile);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to pick video: $e',
        isLoading: false,
      );
    }
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void clearVideo() {
    state = state.copyWith(
      selectedVideo: null,
      description: null,
      error: null,
    );
  }

  void setRecordedVideo(File videoFile) async {
    state = state.copyWith(
      selectedVideo: videoFile,
      isLoading: false,
      error: null,
    );
    // Initialize video player after state update
    await ref.read(videoPlayerControllerNotifierProvider.notifier)
      .initializeController(videoFile);
  }

  Future<void> uploadVideo() async {
    if (state.selectedVideo == null) {
      state = state.copyWith(error: 'No video selected');
      return;
    }

    try {
      final videoServiceInstance = ref.read(videoServiceProvider);
      
      // Validate video before starting upload
      await videoServiceInstance.validateVideo(state.selectedVideo!);
      
      state = state.copyWith(
        isUploading: true,
        error: null,
        uploadProgress: 0,
      );

      await videoServiceInstance.uploadVideo(
        state.selectedVideo!,
        description: state.description,
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );

      // Clear state after successful upload
      state = const VideoUploadState();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isUploading: false,
        uploadProgress: null,
      );
    }
  }

  Future<void> retryUpload() async {
    if (!state.isUploading && state.selectedVideo != null) {
      state = state.copyWith(error: null);
      await uploadVideo();
    }
  }

  Future<void> cancelUpload() async {
    if (state.isUploading) {
      final videoServiceInstance = ref.read(videoServiceProvider);
      await videoServiceInstance.cancelUpload();
      state = state.copyWith(
        isUploading: false,
        uploadProgress: null,
      );
    }
  }

  void removeSelectedVideo() async {
    // Dispose video player first
    await ref.read(videoPlayerControllerNotifierProvider.notifier).disposeController();
    // Then clear state
    state = const VideoUploadState();
  }
}
