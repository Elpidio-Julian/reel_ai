import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/video_comment.dart';
import '../models/user.dart';
import '../repositories/video_comment_repository.dart';
import 'auth_state.dart';

part 'video_comment_provider.g.dart';

@riverpod
VideoCommentRepository videoCommentRepository(Ref ref) {
  return VideoCommentRepository();
}

@riverpod
class VideoCommentController extends _$VideoCommentController {
  @override
  FutureOr<void> build() async {}

  Future<void> addComment(String videoId, String text, {String? parentCommentId}) async {
    state = const AsyncLoading();
    try {
      final User? user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User must be logged in to comment');

      final comment = VideoComment(
        id: const Uuid().v4(),
        videoId: videoId,
        userId: user.id,
        text: text,
        timestamp: DateTime.now(),
        parentCommentId: parentCommentId,
        userDisplayName: user.displayName,
      );

      await ref.read(videoCommentRepositoryProvider).addComment(comment);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      debugPrint('Error adding comment: $e\n$stack');
    }
  }

  Future<void> deleteComment(VideoComment comment) async {
    state = const AsyncLoading();
    try {
      final User? user = ref.read(authStateProvider).value;
      if (user == null || user.id != comment.userId) {
        throw Exception('Unauthorized to delete this comment');
      }
      await ref.read(videoCommentRepositoryProvider).deleteComment(comment);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      debugPrint('Error deleting comment: $e\n$stack');
    }
  }

  Future<void> toggleCommentLike(String commentId, bool like) async {
    state = const AsyncLoading();
    try {
      await ref.read(videoCommentRepositoryProvider).toggleCommentLike(commentId, like);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      debugPrint('Error toggling comment like: $e\n$stack');
    }
  }
}

@riverpod
Stream<List<VideoComment>> videoComments(Ref ref, String videoId) {
  return ref.watch(videoCommentRepositoryProvider).streamVideoComments(videoId);
}

@riverpod
Future<List<VideoComment>> commentReplies(Ref ref, String commentId) {
  return ref.watch(videoCommentRepositoryProvider).getCommentReplies(commentId);
}

// Provider for paginated video comments
@riverpod
Future<List<VideoComment>> paginatedVideoComments(
  Ref ref,
  String videoId, {
  String? lastCommentId,
  int limit = 20,
}) {
  return ref.watch(videoCommentRepositoryProvider).getVideoComments(
    videoId,
    lastCommentId: lastCommentId,
    limit: limit,
  );
}

// Provider to check if user has liked a comment
@riverpod
Future<bool> hasUserLikedComment(Ref ref, String commentId) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;
  
  return ref.watch(videoCommentRepositoryProvider).hasUserLikedComment(commentId, user.id);
} 