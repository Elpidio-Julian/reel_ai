import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/video_service.dart';

part 'video_upload_provider.g.dart';

class VideoUploadState {
  final bool isLoading;
  final String? error;
  final File? selectedVideo;
  final String? description;
  final bool isUploading;

  const VideoUploadState({
    this.isLoading = false,
    this.error,
    this.selectedVideo,
    this.description,
    this.isUploading = false,
  });

  VideoUploadState copyWith({
    bool? isLoading,
    String? error,
    File? selectedVideo,
    String? description,
    bool? isUploading,
  }) {
    return VideoUploadState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedVideo: selectedVideo ?? this.selectedVideo,
      description: description ?? this.description,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

@Riverpod(keepAlive: true)
VideoService videoService(VideoServiceRef ref) {
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

    state = state.copyWith(isUploading: true);
    try {
      final videoServiceInstance = ref.read(videoServiceProvider);
      await videoServiceInstance.uploadVideo(
        state.selectedVideo!,
        description: state.description,
      );
      
      state = state.copyWith(
        isUploading: false,
        selectedVideo: null,
        description: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to upload video: $e',
        isUploading: false,
      );
    }
  }
}
