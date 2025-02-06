import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import '../../../providers/video_upload_provider.dart';
import '../../camera/camera_recording_screen.dart';

class UploadTab extends ConsumerStatefulWidget {
  const UploadTab({super.key});

  @override
  ConsumerState<UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends ConsumerState<UploadTab> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _controller?.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.videos,
      Permission.photos,
    ];

    // Check current status
    final statuses = await Future.wait(
      permissions.map((permission) => permission.status),
    );

    // If any permission is not granted, show settings dialog
    if (statuses.any((status) => !status.isGranted)) {
      if (!mounted) return;
      
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text('Camera, microphone, and media access are required to record and select videos. Would you like to grant these permissions?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Settings'),
            ),
          ],
        ),
      );

      if (result == true) {
        await openAppSettings();
        return;
      }
      return;
    }

    // All permissions granted, proceed to camera
    if (!mounted) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraRecordingScreen(),
      ),
    );
  }

  Future<void> _showVideoOptions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Record New Video'),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (action == 'gallery') {
      ref.read(videoUploadControllerProvider.notifier).pickVideo();
    } else if (action == 'camera') {
      await _checkAndRequestPermissions();
    }
  }

  Future<void> _initializeVideo(String path) async {
    if (_isInitializing) return;
    _isInitializing = true;
    
    try {
      final oldController = _controller;
      final newController = VideoPlayerController.file(File(path));
      
      await newController.initialize();
      await oldController?.dispose();
      
      if (mounted) {
        setState(() {
          _controller = newController;
          _isInitializing = false;
        });
        
        _controller?.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoUploadControllerProvider);

    if (state.selectedVideo != null && 
        (_controller == null || state.selectedVideo!.path != _controller!.dataSource)) {
      _initializeVideo(state.selectedVideo!.path);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isLoading)
            const LinearProgressIndicator(),
            
          if (state.isUploading && state.uploadProgress != null)
            Column(
              children: [
                LinearProgressIndicator(value: state.uploadProgress),
                const SizedBox(height: 8),
                Text(
                  '${(state.uploadProgress! * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            
          if (state.error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.shade100,
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            
          if (state.selectedVideo == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file, size: 64),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showVideoOptions,
                      child: const Text('Select or Record Video'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: _controller?.value.aspectRatio ?? 16/9,
                    child: _controller?.value.isInitialized ?? false
                        ? VideoPlayer(_controller!)
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _controller?.pause();
                          ref.read(videoUploadControllerProvider.notifier)
                            .removeSelectedVideo();
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Remove'),
                      ),
                      ElevatedButton.icon(
                        onPressed: state.isUploading
                            ? null
                            : () {
                                ref.read(videoUploadControllerProvider.notifier)
                                  .updateDescription(_descriptionController.text.trim());
                                ref.read(videoUploadControllerProvider.notifier)
                                  .uploadVideo();
                              },
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 