import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/video.dart';
import '../services/video_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

part 'gallery_provider.g.dart';

@Riverpod(keepAlive: true)
VideoService galleryVideoService(Ref ref) {
  return VideoService();
}

@Riverpod(keepAlive: true)
class GalleryController extends _$GalleryController {
  @override
  FutureOr<List<Video>> build() async {
    debugPrint('GalleryController: Initial build');
    return [];
  }

  Future<void> loadDraftVideos() async {
    debugPrint('GalleryController: Loading draft videos');
    state = const AsyncLoading();
    try {
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('GalleryController: Current user: ${user?.uid}');
      if (user == null) {
        debugPrint('GalleryController: No user logged in');
        state = const AsyncData([]);
        return;
      }
      final videos = await ref.read(galleryVideoServiceProvider).getUserDraftVideos(user.uid);
      debugPrint('GalleryController: Loaded ${videos.length} draft videos');
      state = AsyncData(videos);
    } catch (e, stack) {
      debugPrint('GalleryController: Error loading draft videos: $e\n$stack');
      state = AsyncError(e, stack);
    }
  }

  Future<void> loadPublishedVideos() async {
    debugPrint('GalleryController: Loading published videos');
    state = const AsyncLoading();
    try {
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('GalleryController: Current user: ${user?.uid}');
      if (user == null) {
        debugPrint('GalleryController: No user logged in');
        state = const AsyncData([]);
        return;
      }
      final videos = await ref.read(galleryVideoServiceProvider).getUserPublishedVideos(user.uid);
      debugPrint('GalleryController: Loaded ${videos.length} published videos');
      state = AsyncData(videos);
    } catch (e, stack) {
      debugPrint('GalleryController: Error loading published videos: $e\n$stack');
      state = AsyncError(e, stack);
    }
  }

  Future<void> publishVideo(Video video) async {
    try {
      await ref.read(galleryVideoServiceProvider).publishVideo(video.id);
      await loadDraftVideos();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> unpublishVideo(Video video) async {
    try {
      await ref.read(galleryVideoServiceProvider).unpublishVideo(video.id);
      await loadPublishedVideos();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
} 