// Dart imports
import 'dart:io';

// Flutter imports
import 'package:flutter/material.dart';

// Third-party package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

// Local imports
import '../../providers/video_upload_provider.dart';
import '../camera/camera_recording_screen.dart';

class VideoUploadScreen extends ConsumerStatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  ConsumerState<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends ConsumerState<VideoUploadScreen> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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

  void _handleUpload() {
    final description = _descriptionController.text.trim();
    ref.read(videoUploadControllerProvider.notifier)
      .updateDescription(description);
    ref.read(videoUploadControllerProvider.notifier)
      .uploadVideo();
  }

  void _handleRemoveVideo() {
    _controller?.pause();
    _controller?.dispose();
    ref.read(videoUploadControllerProvider.notifier)
      .removeSelectedVideo();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoUploadControllerProvider);

    if (state.selectedVideo != null && 
        (_controller == null || state.selectedVideo!.path != _controller!.dataSource)) {
      _initializeVideo(state.selectedVideo!.path);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
      ),
      body: Padding(
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
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller!),
                    if (!_controller!.value.isPlaying)
                      IconButton(
                        icon: const Icon(
                          Icons.play_circle_outline,
                          size: 60,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                          });
                        },
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: _handleRemoveVideo,
                      ),
                    ),
                  ],
                ),
              )
            else if (!state.isLoading && !state.isUploading)
              const Center(
                child: Text('Select or record a video to upload'),
              ),
            const SizedBox(height: 16),
            if (state.selectedVideo != null) ...[
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: state.isLoading || state.isUploading 
                ? null 
                : _showVideoOptions,
              child: const Text('Add Video'),
            ),
            if (state.selectedVideo != null) ...[
              const SizedBox(height: 16),
              if (state.isUploading)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(videoUploadControllerProvider.notifier)
                            .cancelUpload();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Cancel Upload'),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleUpload,
                        child: const Text('Upload Video'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _handleRemoveVideo,
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
} 