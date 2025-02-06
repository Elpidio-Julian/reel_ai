import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/video.dart';
import '../services/video_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'gallery_provider.g.dart';

@riverpod
VideoService galleryVideoService(GalleryVideoServiceRef ref) {
  return VideoService();
}

@riverpod
class GalleryController extends _$GalleryController {
  @override
  Future<List<Video>> build() async {
    // Start with draft videos by default
    return _loadDraftVideos();
  }

  Future<List<Video>> _loadDraftVideos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    
    final videoService = ref.read(galleryVideoServiceProvider);
    return videoService.getUserDraftVideos(user.uid);
  }

  Future<List<Video>> _loadPublishedVideos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    
    final videoService = ref.read(galleryVideoServiceProvider);
    return videoService.getUserPublishedVideos(user.uid);
  }

  Future<void> loadDraftVideos() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadDraftVideos);
  }

  Future<void> loadPublishedVideos() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadPublishedVideos);
  }

  Future<void> publishVideo(String videoId) async {
    final videoService = ref.read(galleryVideoServiceProvider);
    await videoService.publishVideo(videoId);
    // Reload the current list
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadDraftVideos);
  }

  Future<void> unpublishVideo(String videoId) async {
    final videoService = ref.read(galleryVideoServiceProvider);
    await videoService.unpublishVideo(videoId);
    // Reload the current list
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadPublishedVideos);
  }
} 