import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/video_upload_provider.dart';
import '../../services/camera_service.dart';

final cameraServiceProvider = StateNotifierProvider<CameraService, CameraServiceState>((ref) {
  return CameraService();
});

class CameraRecordingScreen extends ConsumerStatefulWidget {
  const CameraRecordingScreen({super.key});

  @override
  ConsumerState<CameraRecordingScreen> createState() => _CameraRecordingScreenState();
}

class _CameraRecordingScreenState extends ConsumerState<CameraRecordingScreen> {
  String? _lastRecordedVideoPath;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await ref.read(cameraServiceProvider.notifier).initialize();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      await ref.read(cameraServiceProvider.notifier).startRecording();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final videoPath = await ref.read(cameraServiceProvider.notifier).stopRecording();
      if (mounted) {
        setState(() {
          _lastRecordedVideoPath = videoPath;
        });

        if (_lastRecordedVideoPath != null) {
          ref.read(videoUploadControllerProvider.notifier).setRecordedVideo(File(_lastRecordedVideoPath!));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraServiceProvider);

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _initializeCamera,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (cameraState == CameraServiceState.uninitialized || 
        cameraState == CameraServiceState.initializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final cameraService = ref.read(cameraServiceProvider.notifier);
    if (cameraService.controller == null) {
      return const Scaffold(
        body: Center(
          child: Text('Camera not available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Transform.scale(
              scale: 1.0,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 9/16,
                  child: CameraPreview(cameraService.controller!),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (cameraState == CameraServiceState.recording)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Recording',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      cameraState == CameraServiceState.recording 
                          ? Icons.stop 
                          : Icons.fiber_manual_record,
                      color: cameraState == CameraServiceState.recording 
                          ? Colors.red 
                          : Colors.white,
                      size: 64,
                    ),
                    onPressed: cameraState == CameraServiceState.recording 
                        ? _stopRecording 
                        : _startRecording,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
