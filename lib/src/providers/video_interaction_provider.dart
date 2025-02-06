import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/video_interaction.dart';
import '../models/video_stats.dart';
import '../models/user.dart';
import '../repositories/video_interaction_repository.dart';
import 'auth_state.dart';

part 'video_interaction_provider.g.dart';

@Riverpod(keepAlive: true)
VideoInteractionRepository videoInteractionRepository(Ref ref) {
  return VideoInteractionRepository();
}

@Riverpod(keepAlive: true)
class VideoInteractionController extends _$VideoInteractionController {
  @override
  FutureOr<void> build() async {
    // Initial state is void
  }

  Future<void> addInteraction(String videoId, String type) async {
    state = const AsyncLoading();
    
    try {
      final User? user = ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('User must be logged in to interact with videos');
      }

      final interaction = VideoInteraction(
        id: const Uuid().v4(),
        videoId: videoId,
        userId: user.id,
        type: type,
        timestamp: DateTime.now(),
      );

      await ref.read(videoInteractionRepositoryProvider).addInteraction(interaction);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      debugPrint('Error adding interaction: $e\n$stack');
    }
  }

  Future<void> removeInteraction(String videoId, String type) async {
    state = const AsyncLoading();
    
    try {
      final User? user = ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('User must be logged in to interact with videos');
      }

      final interaction = VideoInteraction(
        id: const Uuid().v4(),
        videoId: videoId,
        userId: user.id,
        type: type,
        timestamp: DateTime.now(),
      );

      await ref.read(videoInteractionRepositoryProvider).removeInteraction(interaction);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      debugPrint('Error removing interaction: $e\n$stack');
    }
  }
}

@riverpod
Stream<bool> hasUserInteraction(Ref ref, {required String videoId, required String type}) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);

  return ref.watch(videoInteractionRepositoryProvider)
      .streamUserInteraction(user.id, videoId, type);
}

@riverpod
Future<VideoStats?> videoStats(Ref ref, {required String videoId}) {
  return ref.read(videoInteractionRepositoryProvider).getVideoStats(videoId);
}

@riverpod
Future<List<VideoInteraction>> userVideoInteractions(Ref ref, {required String videoId}) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];

  return ref.read(videoInteractionRepositoryProvider)
      .getUserInteractions(user.id, videoId);
} 