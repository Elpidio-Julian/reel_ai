import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../models/video.dart';
import '../../../providers/published_videos_provider.dart';

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
    _controllers[_currentIndex]?.pause();
    
    setState(() {
      _currentIndex = index;
    });

    // Initialize and play new current video if not already initialized
    await _initializeController(index, videos[index].url);
    if (!_isDisposed) {
      _controllers[index]?.play();
    }

    // Preload adjacent videos
    _preloadAdjacentVideos(videos);
    
    // Cleanup old controllers
    _cleanupControllers(index);
  }

  Widget _buildVideoPlayer(Video video, int index) {
    final controller = _controllers[index];
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        controller?.value.isInitialized == true
            ? Center(
                child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

        // User Info Overlay (bottom)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 179, red: 0, green: 0, blue: 0),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User: ${video.userId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
              ],
            ),
          ),
        ),

        // Play/Pause Overlay (center)
        GestureDetector(
          onTap: () {
            setState(() {
              if (controller?.value.isPlaying == true) {
                controller?.pause();
              } else {
                controller?.play();
              }
            });
          },
          child: Center(
            child: AnimatedOpacity(
              opacity: controller?.value.isPlaying == true ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 128, red: 0, green: 0, blue: 0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller?.value.isPlaying == true
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // Video Progress Indicator
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: controller?.value.isInitialized == true
              ? VideoProgressIndicator(
                  controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.black45,
                  ),
                )
              : const SizedBox.shrink(),
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