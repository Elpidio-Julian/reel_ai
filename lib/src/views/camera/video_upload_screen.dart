import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/video_upload_provider.dart';
import 'package:video_player/video_player.dart';
import '../../services/video_service.dart';
import 'camera_recording_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoUploadScreen extends ConsumerStatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  ConsumerState<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends ConsumerState<VideoUploadScreen> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
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
            children: <Widget>[
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
              const Center(child: CircularProgressIndicator())
            else if (_controller != null && _controller!.value.isInitialized)
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
                  ],
                ),
              )
            else
              const Center(
                child: Text('Select or record a video to upload'),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: state.isLoading ? null : _showVideoOptions,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Video'),
            ),
            if (state.selectedVideo != null) ...[
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => ref.read(videoUploadControllerProvider.notifier).updateDescription(value),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state.isUploading
                    ? null
                    : () => ref.read(videoUploadControllerProvider.notifier).uploadVideo(),
                child: state.isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Video'),
              ),
            ],
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: state.selectedVideo != null
        ? FloatingActionButton(
            onPressed: () {
              _controller?.pause();
              ref.read(videoUploadControllerProvider.notifier).clearVideo();
            },
            child: const Icon(Icons.close),
          )
        : null,
    );
  }
}
