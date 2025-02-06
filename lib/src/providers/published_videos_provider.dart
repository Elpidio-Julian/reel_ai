import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/video.dart';
import '../services/video_service.dart';

part 'published_videos_provider.g.dart';

@Riverpod(keepAlive: true)
VideoService publishedVideoService(Ref ref) {
  return VideoService();
}

@Riverpod(keepAlive: true)
class PublishedVideosController extends _$PublishedVideosController {
  @override
  FutureOr<List<Video>> build() async {
    return [];
  }

  Future<void> loadPublishedVideos() async {
    state = const AsyncLoading();
    try {
      final videos = await ref.read(publishedVideoServiceProvider).getPublishedVideos();
      state = AsyncData(videos);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
} 