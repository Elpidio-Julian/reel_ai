import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/video.dart';

class VideoShareSheet extends StatelessWidget {
  final Video video;
  final bool allowDownload;

  const VideoShareSheet({
    super.key,
    required this.video,
    this.allowDownload = false,
  });

  Future<void> _copyLink(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: video.url));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to copy link. Please try again.')),
        );
      }
    }
  }

  Future<void> _shareVideo() async {
    try {
      await Share.share(
        'Check out this video: ${video.url}',
        subject: video.description ?? 'Check out this video',
      );
    } catch (e) {
      debugPrint('Error sharing video: $e');
      // The share sheet will handle its own error states
    }
  }

  Future<void> _downloadVideo(BuildContext context) async {
    if (!allowDownload) return;

    try {
      // TODO: Implement video download functionality
      // This would require additional permissions and download management
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download feature coming soon!')),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to download video. Please try again later.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Share options
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Share to',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ShareOption(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () {
                        _shareVideo();
                        Navigator.pop(context);
                      },
                    ),
                    _ShareOption(
                      icon: Icons.link,
                      label: 'Copy Link',
                      onTap: () => _copyLink(context),
                    ),
                    if (allowDownload)
                      _ShareOption(
                        icon: Icons.download,
                        label: 'Download',
                        onTap: () {
                          _downloadVideo(context);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 