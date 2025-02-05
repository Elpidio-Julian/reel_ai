import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/video_service.dart';
import 'video_upload_screen.dart';

class CameraRecordingScreen extends StatefulWidget {
  const CameraRecordingScreen({super.key});

  @override
  State<CameraRecordingScreen> createState() => _CameraRecordingScreenState();
}

class _CameraRecordingScreenState extends State<CameraRecordingScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isInitialized = false;
  String? _errorMessage;
  final int _maxDuration = 60; // Maximum duration in seconds
  DateTime? _recordingStartTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera and microphone permissions
      final cameraPermission = await Permission.camera.request();
      final microphone = await Permission.microphone.request();
      
      if (cameraPermission.isDenied || microphone.isDenied) {
        setState(() {
          _errorMessage = 'Camera and microphone permissions are required';
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      // Use the first available camera (usually the back camera)
      final cameraDesc = cameras.first;
      _controller = CameraController(
        cameraDesc,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (_isRecording) {
      try {
        final file = await _controller!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _recordingStartTime = null;
        });

        // Navigate to upload screen with the recorded video
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VideoUploadScreen(videoFile: File(file.path)),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to stop recording: $e';
        });
      }
    } else {
      try {
        await _controller!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recordingStartTime = DateTime.now();
        });

        // Auto-stop recording after maximum duration
        Future.delayed(Duration(seconds: _maxDuration), () {
          if (_isRecording) {
            _toggleRecording();
          }
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to start recording: $e';
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            Center(
              child: CameraPreview(_controller!),
            ),
            
            // Recording indicator and timer
            if (_isRecording)
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          final duration = _recordingStartTime != null
                              ? DateTime.now().difference(_recordingStartTime!)
                              : Duration.zero;
                          return Text(
                            _formatDuration(duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // Recording button
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      color: _isRecording ? Colors.red : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
