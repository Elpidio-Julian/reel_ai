import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/video_service.dart';

part 'video_upload_provider.g.dart';

class VideoUploadState {
  final bool isLoading;
  final String? error;
  final File? selectedVideo;
  final String? description;
  final bool isUploading;
  final double? uploadProgress;

  const VideoUploadState({
    this.isLoading = false,
    this.error,
    this.selectedVideo,
    this.description,
    this.isUploading = false,
    this.uploadProgress,
  });

  VideoUploadState copyWith({
    bool? isLoading,
    String? error,
    File? selectedVideo,
    String? description,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return VideoUploadState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedVideo: selectedVideo ?? this.selectedVideo,
      description: description ?? this.description,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

@Riverpod(keepAlive: true)
VideoService videoService(Ref ref) {
  return VideoService();
}

@Riverpod(keepAlive: true)
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
        state = state.copyWith(
          selectedVideo: File(video.path),
          isLoading: false,
        );
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

  void setRecordedVideo(File videoFile) {
    state = state.copyWith(
      selectedVideo: videoFile,
      isLoading: false,
      error: null,
    );
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

  void removeSelectedVideo() {
    state = state.copyWith(
      selectedVideo: null,
      description: null,
      error: null,
    );
  }
}
