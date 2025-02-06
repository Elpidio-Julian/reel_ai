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
  VideoPlayerController? _currentController;

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
    _currentController?.dispose();
    super.dispose();
  }

  Future<void> _initializeController(String videoUrl) async {
    if (_currentController != null) {
      await _currentController!.dispose();
    }

    _currentController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    
    try {
      await _currentController!.initialize();
      await _currentController!.play();
      await _currentController!.setLooping(true);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing video controller: $e');
    }
  }

  Widget _buildVideoPlayer(Video video) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        _currentController?.value.isInitialized == true
            ? Center(
                child: AspectRatio(
                  aspectRatio: _currentController!.value.aspectRatio,
                  child: VideoPlayer(_currentController!),
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
              if (_currentController?.value.isPlaying == true) {
                _currentController?.pause();
              } else {
                _currentController?.play();
              }
            });
          },
          child: Center(
            child: AnimatedOpacity(
              opacity: _currentController?.value.isPlaying == true ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 128, red: 0, green: 0, blue: 0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _currentController?.value.isPlaying == true
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
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

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: videos.length,
          onPageChanged: (index) {
            _initializeController(videos[index].url);
          },
          itemBuilder: (context, index) {
            final video = videos[index];
            
            // Initialize the first video
            if (index == 0 && _currentController == null) {
              _initializeController(video.url);
            }

            return _buildVideoPlayer(video);
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