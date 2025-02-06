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
        id: const Uuid().v4(), // This ID won't be used for removal
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

// Provider for checking if current user has interacted with a video
@riverpod
Future<bool> hasUserInteraction(
  Ref ref,
  String videoId,
  String type,
) async {
  final User? user = ref.watch(authStateProvider).value;
  if (user == null) return false;

  return ref.watch(videoInteractionRepositoryProvider)
      .hasUserInteraction(user.id, videoId, type);
}

// Provider for video stats
@riverpod
Stream<VideoStats?> videoStats(Ref ref, String videoId) {
  return ref.watch(videoInteractionRepositoryProvider).streamVideoStats(videoId);
}

// Provider for user interactions with a video
@riverpod
Future<List<VideoInteraction>> userVideoInteractions(
  Ref ref,
  String videoId,
) async {
  final User? user = ref.watch(authStateProvider).value;
  if (user == null) return [];

  return ref.watch(videoInteractionRepositoryProvider)
      .getUserInteractions(user.id, videoId);
} 