import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/video_upload_provider.dart';
import 'package:video_player/video_player.dart';
import '../../services/video_service.dart';
import 'camera_recording_screen.dart';

class VideoUploadScreen extends ConsumerStatefulWidget {
  final File? videoFile;
  
  const VideoUploadScreen({
    super.key,
    this.videoFile,
  });

  @override
  ConsumerState<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends ConsumerState<VideoUploadScreen> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoFile != null) {
      _initializeVideo(widget.videoFile!.path);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _navigateToCameraRecording() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraRecordingScreen(),
      ),
    );
  }

  Future<void> _initializeVideo(String path) async {
    if (_isInitializing) return;
    _isInitializing = true;
    
    try {
      final oldController = _controller;
      final newController = VideoPlayerController.file(File(path));
      
      // Initialize new controller
      await newController.initialize();
      
      // Dispose old controller after new one is ready
      await oldController?.dispose();
      
      if (mounted) {
        setState(() {
          _controller = newController;
          _isInitializing = false;
        });
        
        // Auto-play the first time
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

    // Initialize video player when a video is selected
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: state.isLoading 
                    ? null 
                    : () => ref.read(videoUploadControllerProvider.notifier).pickVideo(),
                  icon: const Icon(Icons.video_library),
                  label: const Text('Choose Video'),
                ),
                ElevatedButton.icon(
                  onPressed: state.isLoading 
                    ? null 
                    : _navigateToCameraRecording,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Record Video'),
                ),
              ],
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
