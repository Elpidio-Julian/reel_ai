import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../preview/video_preview_screen.dart';
import '../preview/video_trimmer_screen.dart';
import '../../services/camera_service.dart';
import '../../services/video_storage_service.dart';
import '../../services/recording_timer_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraService? _cameraService;
  VideoStorageService? _storageService;
  RecordingTimerService? _timerService;
  String? _errorMessage;
  bool _isDisposed = false;
  Offset? _focusPoint;
  double _baseScaleFactor = 1.0;
  Future<void>? _initializationFuture;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    WidgetsBinding.instance.addObserver(this);
    _initializationFuture = _initializeServices();
  }

  Future<void> _initializeServices() async {
    if (_isDisposed) return;

    try {
      // Create services
      _storageService = VideoStorageService();
      _timerService = RecordingTimerService(
        maxDuration: const Duration(minutes: 3),
        onMaxDurationReached: _handleMaxDurationReached,
      );
      _cameraService = CameraService();

      // Initialize camera with a timeout to avoid hanging
      await _cameraService!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Camera initialization timed out.");
        },
      );
      
      if (!mounted) return;
    } catch (e) {
      await _disposeResources();
      throw Exception('Failed to initialize camera: $e');
    }
  }

  Future<void> _disposeResources() async {
    try {
      // Stop recording if active
      if (_cameraService?.isRecording == true) {
        await _cameraService?.stopRecording();
      }

      // Dispose in reverse order of initialization
      await _cameraService?.dispose();
      _timerService?.dispose();
      
      _cameraService = null;
      _timerService = null;
      _storageService = null;
    } catch (e) {
      debugPrint('Error disposing resources: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposeResources();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _disposeResources();
        break;
      case AppLifecycleState.resumed:
        if (_cameraService?.isInitialized != true) {
          _initializationFuture = _initializeServices();
          setState(() {}); // Trigger rebuild with new future
        }
        break;
      default:
        break;
    }
  }

  bool get _isReady => 
    _cameraService != null && 
    _cameraService!.isInitialized && 
    _cameraService!.controller != null;

  // Update all service calls to use null-safe access
  void _handleMaxDurationReached() {
    if (!_isDisposed && _isReady) {
      _toggleRecording();
    }
  }

  Future<void> _toggleRecording() async {
    if (!_isReady) return;

    try {
      if (_cameraService!.isRecording) {
        _timerService?.stop();
        final String videoPath = await _cameraService!.stopRecording();
        await _navigateToPreview(videoPath);
      } else {
        await _cameraService!.startRecording();
        _timerService?.start();
      }
    } catch (e) {
      _timerService?.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording video: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _navigateToPreview(String videoPath) async {
    // Properly dispose resources before navigation
    await _disposeResources();
    
    if (!mounted) return;

    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreviewScreen(
          videoPath: videoPath,
        ),
      ),
    );
    
    if (!mounted) return;

    // Handle the result
    if (result != null) {
      await _handleVideoResult(result);
    } else {
      await _storageService?.deleteVideo(videoPath);
    }

    // Reinitialize camera after returning
    if (mounted) {
      await _initializeServices();
    }
  }

  Future<void> _handleVideoResult(String videoPath) async {
    if (!mounted) return;
    
    try {
      final String savedPath = await _storageService?.saveVideo(videoPath) ?? '';
      
      if (savedPath.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving video: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    await _disposeResources();
    
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
      );
      
      if (!mounted) return;
      
      if (video != null) {
        final VideoPlayerController controller = VideoPlayerController.file(File(video.path));
        await controller.initialize();
        final Duration videoDuration = controller.value.duration;
        await controller.dispose();

        final maxDuration = _timerService?.maxDuration ?? const Duration(minutes: 3);
        if (videoDuration.compareTo(maxDuration) > 0) {
          if (!mounted) return;
          
          final String? trimmedPath = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) => VideoTrimmerScreen(
                videoPath: video.path,
                maxDuration: maxDuration,
              ),
            ),
          );

          if (!mounted) return;

          if (trimmedPath != null) {
            await _handleVideoResult(trimmedPath);
          }
        } else {
          await _handleVideoResult(video.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking video: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // Reinitialize camera
      if (mounted) {
        await _initializeServices();
      }
    }
  }

  IconData _getFlashIcon() {
    switch (_cameraService?.controller?.value.flashMode ?? FlashMode.off) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
    }
  }

  Future<void> _toggleFlash() async {
    if (!_isReady || !mounted) return;

    try {
      final controller = _cameraService!.controller!;
      FlashMode newMode;
      switch (controller.value.flashMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
          newMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          newMode = FlashMode.off;
          break;
      }

      await controller.setFlashMode(newMode);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    await _cameraService?.switchCamera();
    if (mounted) setState(() {});
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (!_isReady || !mounted) return;

    try {
      final controller = _cameraService!.controller!;
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();
      
      final double scale = (_baseScaleFactor * details.scale).clamp(
        minZoom,
        maxZoom,
      );

      await controller.setZoomLevel(scale);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error updating zoom: $e');
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScaleFactor = 1.0;
  }

  Future<void> _handleTapToFocus(TapDownDetails details) async {
    if (!_isReady || !mounted) return;

    try {
      final controller = _cameraService!.controller!;
      final box = context.findRenderObject() as RenderBox;
      final point = box.globalToLocal(details.globalPosition);
      
      // Convert tap position to normalized coordinates (0.0 to 1.0)
      final double x = point.dx / box.size.width;
      final double y = point.dy / box.size.height;

      // Set focus point and mode
      await controller.setFocusMode(FocusMode.locked);
      await controller.setFocusPoint(Offset(x, y));
      await controller.setFocusMode(FocusMode.auto);

      // Show focus indicator
      if (mounted) {
        setState(() {
          _focusPoint = point;
        });
      }

      // Hide focus indicator and reset to continuous auto focus after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _focusPoint = null;
        });
        // Reset to continuous auto focus
        await controller.setFocusMode(FocusMode.auto);
      }
    } catch (e) {
      debugPrint('Error setting focus: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting focus: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildErrorWidget(String error) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                error,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _initializationFuture = _initializeServices();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraUI() {
    if (!_isReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final previewRatio = _cameraService!.controller!.value.aspectRatio;
    
    // Calculate the preview scaling
    final scale = deviceRatio > previewRatio 
      ? deviceRatio / previewRatio 
      : previewRatio / deviceRatio;

    return PopScope(
      canPop: !_cameraService!.isRecording,
      onPopInvokedWithResult: (bool didPop) async {
        if (!didPop && _cameraService!.isRecording) {
          await _toggleRecording();
          return false;
        }
        return true;
      } as PopInvokedWithResultCallback<bool>,
      child: Scaffold(
        backgroundColor: Colors.red.withAlpha((0.2 * 255).round()),
        body: SafeArea(
          child: Stack(
            children: [
              // Camera preview with scaling
              Transform.scale(
                scale: scale,
                child: Center(
                  child: GestureDetector(
                    onTapDown: _handleTapToFocus,
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_cameraService!.controller!),
                        // Focus point indicator
                        if (_focusPoint != null)
                          Positioned(
                            left: _focusPoint!.dx - 20,
                            top: _focusPoint!.dy - 20,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Zoom level indicator
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.5 * 255).round()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_baseScaleFactor.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              // Recording duration indicator
              if (_cameraService!.isRecording)
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.5 * 255).round()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_timerService?.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Camera controls
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library),
                        color: Colors.white,
                        onPressed: _cameraService!.isRecording ? null : _pickFromGallery,
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios),
                        color: Colors.white,
                        onPressed: _cameraService!.isRecording ? null : _switchCamera,
                      ),
                      
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_cameraService!.isRecording)
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(
                                value: (_timerService?.duration.inSeconds ?? 0) / 
                                      (_timerService?.maxDuration.inSeconds ?? 1),
                                color: Colors.red,
                                backgroundColor: Colors.red.withAlpha((0.2 * 255).round()),
                              ),
                            ),
                          IconButton(
                            icon: Icon(
                              _cameraService!.isRecording ? Icons.stop : Icons.fiber_manual_record,
                              size: 50,
                            ),
                            color: _cameraService!.isRecording ? Colors.red : Colors.white,
                            onPressed: _toggleRecording,
                          ),
                        ],
                      ),
                      
                      IconButton(
                        icon: Icon(_getFlashIcon()),
                        color: Colors.white,
                        onPressed: _cameraService!.isRecording ? null : _toggleFlash,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _errorMessage != null
          ? _buildErrorWidget(_errorMessage!)
          : _buildCameraUI();
      },
    );
  }
} 