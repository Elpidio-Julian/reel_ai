import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/video.dart';
import '../../../providers/gallery_provider.dart';
import '../../../widgets/video_preview_dialog.dart';

final selectedGalleryTabProvider = StateProvider<int>((ref) => 0);

class GalleryTab extends ConsumerStatefulWidget {
  const GalleryTab({super.key});

  @override
  ConsumerState<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends ConsumerState<GalleryTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      ref.read(selectedGalleryTabProvider.notifier).state = _tabController.index;
      if (_tabController.index == 0) {
        ref.read(galleryControllerProvider.notifier).loadDraftVideos();
      } else {
        ref.read(galleryControllerProvider.notifier).loadPublishedVideos();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showVideoPreview(Video video) {
    showDialog(
      context: context,
      builder: (context) => VideoPreviewDialog(
        video: video,
        onPublish: video.status == Video.statusReady || video.status == Video.statusDraft
            ? () => ref.read(galleryControllerProvider.notifier).publishVideo(video.id)
            : null,
        onUnpublish: video.status == Video.statusPublished
            ? () => ref.read(galleryControllerProvider.notifier).unpublishVideo(video.id)
            : null,
      ),
    );
  }

  Widget _buildVideoGrid(List<Video> videos) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return GestureDetector(
          onTap: () => _showVideoPreview(video),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (video.thumbnailUrl != null)
                Image.network(
                  video.thumbnailUrl!,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    video.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final videos = ref.watch(galleryControllerProvider);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Drafts'),
            Tab(text: 'Published'),
          ],
        ),
        Expanded(
          child: videos.when(
            data: (videoList) => _buildVideoGrid(videoList),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          ),
        ),
      ],
    );
  }
} 