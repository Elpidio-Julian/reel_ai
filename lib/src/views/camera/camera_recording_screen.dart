import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/video_upload_provider.dart';

class CameraRecordingScreen extends ConsumerStatefulWidget {
  const CameraRecordingScreen({super.key});

  @override
  ConsumerState<CameraRecordingScreen> createState() => _CameraRecordingScreenState();
}

class _CameraRecordingScreenState extends ConsumerState<CameraRecordingScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isInitialized = false;
  String? _errorMessage;
  final int _maxDuration = 60; // Maximum duration in seconds
  DateTime? _recordingStartTime;
  String? _lastRecordedVideoPath;
  Map<Permission, PermissionStatus> _permissionStatus = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.videos,
      Permission.photos,
    ];

    _permissionStatus = Map.fromEntries(
      await Future.wait(
        permissions.map((permission) async {
          final status = await permission.status;
          return MapEntry(permission, status);
        }),
      ),
    );

    bool hasAllPermissions = _permissionStatus.values.every(
      (status) => status.isGranted,
    );

    if (hasAllPermissions) {
      _initializeCamera();
    } else {
      setState(() {}); // Trigger rebuild to show permission UI
    }
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.videos,
      Permission.photos,
    ];

    await Future.wait(
      permissions.map((permission) => permission.request()),
    );

    await _checkPermissions();
  }

  void _openAppSettings() async {
    if (await openAppSettings()) {
      // Wait for the user to return from settings
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please check permissions and return to the app'),
          ),
        );
      }
    }
  }

  Widget _buildPermissionUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Access'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Required Permissions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPermissionItem(
              'Camera',
              _permissionStatus[Permission.camera] ?? PermissionStatus.denied,
              Icons.camera_alt,
            ),
            _buildPermissionItem(
              'Microphone',
              _permissionStatus[Permission.microphone] ?? PermissionStatus.denied,
              Icons.mic,
            ),
            _buildPermissionItem(
              'Videos',
              _permissionStatus[Permission.videos] ?? PermissionStatus.denied,
              Icons.video_library,
            ),
            _buildPermissionItem(
              'Photos',
              _permissionStatus[Permission.photos] ?? PermissionStatus.denied,
              Icons.photo_library,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _requestPermissions,
              child: const Text('Grant Permissions'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _openAppSettings,
              child: const Text('Open App Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(String name, PermissionStatus status, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                Text(
                  _getPermissionStatusText(status),
                  style: TextStyle(
                    fontSize: 12,
                    color: status.isGranted ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            status.isGranted ? Icons.check_circle : Icons.error,
            color: status.isGranted ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  String _getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      default:
        return 'Unknown';
    }
  }

  Future<void> _initializeCamera() async {
    try {
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
        imageFormatGroup: Platform.isAndroid 
            ? ImageFormatGroup.yuv420 
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      // Set up video recording capabilities
      await _controller!.prepareForVideoRecording();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing camera: $e';
      });
    }
  }

  Future<void> _startRecording() async {
    if (!_controller!.value.isInitialized || _isRecording) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingStartTime = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error starting recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) {
      return;
    }

    try {
      final file = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _lastRecordedVideoPath = file.path;
      });

      // Return to video upload screen with the recorded video
      if (mounted && _lastRecordedVideoPath != null) {
        ref.read(videoUploadControllerProvider.notifier).setRecordedVideo(File(_lastRecordedVideoPath!));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error stopping recording: $e';
        _isRecording = false;
        _recordingStartTime = null;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Video')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermissions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show permission UI if any required permission is not granted
    if (_permissionStatus.isEmpty || _permissionStatus.values.any((status) => !status.isGranted)) {
      return _buildPermissionUI();
    }

    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final remainingDuration = _recordingStartTime != null
        ? Duration(seconds: _maxDuration - DateTime.now().difference(_recordingStartTime!).inSeconds)
        : const Duration(seconds: 0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Record Video'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 1.0,
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                  if (_isRecording)
                    Positioned(
                      top: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(remainingDuration),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_lastRecordedVideoPath != null)
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: () {
                          ref.read(videoUploadControllerProvider.notifier)
                              .setRecordedVideo(File(_lastRecordedVideoPath!));
                          Navigator.pop(context);
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        _isRecording ? Icons.stop_circle : Icons.circle,
                        color: Colors.red,
                        size: 72,
                      ),
                      onPressed: _isRecording ? _stopRecording : _startRecording,
                    ),
                    if (_lastRecordedVideoPath != null)
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            _lastRecordedVideoPath = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
