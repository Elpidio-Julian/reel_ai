import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video.dart';
import '../models/video_interaction.dart';
import '../providers/video_interaction_provider.dart';

class VideoActionBar extends ConsumerStatefulWidget {
  final Video video;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;

  const VideoActionBar({
    super.key,
    required this.video,
    required this.onCommentTap,
    required this.onShareTap,
  });

  @override
  ConsumerState<VideoActionBar> createState() => _VideoActionBarState();
}

class _VideoActionBarState extends ConsumerState<VideoActionBar> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    HapticFeedback.mediumImpact();
    _likeAnimationController.forward().then((_) => _likeAnimationController.reverse());
    
    final hasLiked = await ref.read(hasUserInteractionProvider(widget.video.id, VideoInteraction.typeLike).future);
    if (hasLiked) {
      await ref.read(videoInteractionControllerProvider.notifier).removeInteraction(
        widget.video.id,
        VideoInteraction.typeLike,
      );
    } else {
      await ref.read(videoInteractionControllerProvider.notifier).addInteraction(
        widget.video.id,
        VideoInteraction.typeLike,
      );
    }
  }

  Future<void> _handleSave() async {
    final hasSaved = await ref.read(hasUserInteractionProvider(widget.video.id, VideoInteraction.typeSave).future);
    if (hasSaved) {
      await ref.read(videoInteractionControllerProvider.notifier).removeInteraction(
        widget.video.id,
        VideoInteraction.typeSave,
      );
    } else {
      await ref.read(videoInteractionControllerProvider.notifier).addInteraction(
        widget.video.id,
        VideoInteraction.typeSave,
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String count,
    bool isActive = false,
    Animation<double>? animation,
  }) {
    final button = Container(
      margin: const EdgeInsets.only(top: 8.0),
      width: 48.0,
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              icon,
              color: isActive ? Colors.red : Colors.white,
              size: 32.0,
            ),
            onPressed: onTap,
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );

    if (animation != null) {
      return ScaleTransition(
        scale: animation,
        child: button,
      );
    }

    return button;
  }

  @override
  Widget build(BuildContext context) {
    final videoStats = ref.watch(videoStatsProvider(widget.video.id));
    final hasLiked = ref.watch(hasUserInteractionProvider(widget.video.id, VideoInteraction.typeLike));
    final hasSaved = ref.watch(hasUserInteractionProvider(widget.video.id, VideoInteraction.typeSave));

    return Container(
      width: 72.0,
      margin: const EdgeInsets.only(right: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            children: [
              _buildActionButton(
                icon: Icons.favorite,
                onTap: _handleLike,
                count: videoStats.when(
                  data: (stats) => '${stats?.likeCount ?? 0}',
                  loading: () => '0',
                  error: (_, __) => '0',
                ),
                isActive: hasLiked.when(
                  data: (liked) => liked,
                  loading: () => false,
                  error: (_, __) => false,
                ),
                animation: _likeAnimation,
              ),
              _buildActionButton(
                icon: Icons.comment,
                onTap: widget.onCommentTap,
                count: videoStats.when(
                  data: (stats) => '${stats?.commentCount ?? 0}',
                  loading: () => '0',
                  error: (_, __) => '0',
                ),
              ),
              _buildActionButton(
                icon: Icons.share,
                onTap: widget.onShareTap,
                count: videoStats.when(
                  data: (stats) => '${stats?.shareCount ?? 0}',
                  loading: () => '0',
                  error: (_, __) => '0',
                ),
              ),
              _buildActionButton(
                icon: Icons.bookmark,
                onTap: _handleSave,
                count: videoStats.when(
                  data: (stats) => '${stats?.saveCount ?? 0}',
                  loading: () => '0',
                  error: (_, __) => '0',
                ),
                isActive: hasSaved.when(
                  data: (saved) => saved,
                  loading: () => false,
                  error: (_, __) => false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
} 