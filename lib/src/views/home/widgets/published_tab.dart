import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../models/video.dart';
import '../../../models/video_interaction.dart';
import '../../../providers/published_videos_provider.dart';
import '../../../providers/video_interaction_provider.dart';
import '../../../widgets/video_action_bar.dart';
import '../../../widgets/video_comments_sheet.dart';
import '../../../widgets/video_share_sheet.dart';
import '../../../widgets/double_tap_like_overlay.dart';

class PublishedTab extends ConsumerStatefulWidget {
  const PublishedTab({super.key});

  @override
  ConsumerState<PublishedTab> createState() => _PublishedTabState();
}

class _PublishedTabState extends ConsumerState<PublishedTab> {
  // Keep track of three controllers for current, previous, and next videos
  final Map<int, VideoPlayerController> _controllers = {};
  int _currentIndex = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Load published videos initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(publishedVideosControllerProvider.notifier).loadPublishedVideos();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  Future<void> _initializeController(int index, String videoUrl) async {
    if (_isDisposed) return;

    // If controller already exists and is initialized, do nothing
    if (_controllers.containsKey(index) && _controllers[index]!.value.isInitialized) {
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _controllers[index] = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      
      // Only play if this is the current video
      if (index == _currentIndex && !_isDisposed) {
        await controller.play();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing video controller at index $index: $e');
    }
  }

  void _preloadAdjacentVideos(List<Video> videos) {
    // Preload previous video if it exists
    if (_currentIndex > 0) {
      _initializeController(_currentIndex - 1, videos[_currentIndex - 1].url);
    }
    
    // Preload next video if it exists
    if (_currentIndex < videos.length - 1) {
      _initializeController(_currentIndex + 1, videos[_currentIndex + 1].url);
    }
  }

  void _cleanupControllers(int currentIndex) {
    // Keep only controllers for current, previous, and next videos
    final validIndices = {
      currentIndex - 1,
      currentIndex,
      currentIndex + 1,
    };

    _controllers.removeWhere((index, controller) {
      if (!validIndices.contains(index)) {
        controller.dispose();
        return true;
      }
      return false;
    });
  }

  Future<void> _onPageChanged(int index, List<Video> videos) async {
    // Pause current video
    if (_controllers[_currentIndex] != null) {
      _controllers[_currentIndex]!.pause();
    }
    
    setState(() {
      _currentIndex = index;
    });

    // Initialize and play new current video if not already initialized
    await _initializeController(index, videos[index].url);
    if (!_isDisposed && _controllers[index] != null) {
      _controllers[index]!.play();
    }

    // Preload adjacent videos
    _preloadAdjacentVideos(videos);
    
    // Cleanup old controllers
    _cleanupControllers(index);
  }

  void _showComments(Video video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoCommentsSheet(video: video),
    );
  }

  void _showShareMenu(Video video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoShareSheet(video: video),
    );
  }

  Widget _buildVideoPlayer(Video video, int index) {
    final controller = _controllers[index];
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player with double tap like overlay
        DoubleTapLikeOverlay(
          onLike: () {
            HapticFeedback.mediumImpact();
            ref.read(videoInteractionControllerProvider.notifier)
                .addInteraction(video.id, VideoInteraction.typeLike)
                .catchError((e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to like video. Please try again later.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              return null;
            });
          },
          child: controller != null && controller.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    });
                  },
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ),

        // Play/Pause indicator
        if (controller != null && controller.value.isInitialized && !controller.value.isPlaying)
          const Center(
            child: Icon(
              Icons.play_arrow,
              size: 80,
              color: Colors.white70,
            ),
          ),

        // Video progress indicator
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: controller != null && controller.value.isInitialized
              ? VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.black45,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Action bar
        Positioned(
          right: 0,
          bottom: 80,
          child: VideoActionBar(
            video: video,
            onCommentTap: () => _showComments(video),
            onShareTap: () => _showShareMenu(video),
          ),
        ),

        // Video info overlay
        Positioned(
          left: 16,
          right: 88,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (video.userDisplayName != null)
                Row(
                  children: [
                    if (video.userProfileImage != null)
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(video.userProfileImage!),
                      )
                    else
                      CircleAvatar(
                        radius: 16,
                        child: Text(video.userDisplayName![0].toUpperCase()),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      video.userDisplayName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              if (video.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  video.description!,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (video.hashtags != null && video.hashtags!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  video.hashtags!.map((tag) => '#$tag').join(' '),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 230, red: 255, green: 255, blue: 255),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (video.music != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      video.music!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final publishedVideos = ref.watch(publishedVideosControllerProvider);

    return publishedVideos.when(
      data: (videos) {
        if (videos.isEmpty) {
          return const Center(child: Text('No published videos found'));
        }

        // Initialize first video if not already initialized
        if (_controllers.isEmpty) {
          _initializeController(0, videos[0].url);
          _preloadAdjacentVideos(videos);
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: videos.length,
          onPageChanged: (index) => _onPageChanged(index, videos),
          itemBuilder: (context, index) {
            return _buildVideoPlayer(videos[index], index);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
} 