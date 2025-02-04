import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../preview/video_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isRecording = false;
  ResolutionPreset _resolution = ResolutionPreset.medium;
  FlashMode _flashMode = FlashMode.off;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  double _baseScaleFactor = 1.0;
  String? _errorMessage;
  bool _isDisposed = false;

  // Add recording timer variables
  static const Duration _maxRecordingDuration = Duration(minutes: 3);
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _isDisposed = true;
    _disposeCamera();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    try {
      final CameraController? controller = _controller;
      if (controller != null && controller.value.isInitialized) {
        await controller.dispose();
      }
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Don't do anything if we haven't initialized yet
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _disposeCamera();
        break;
      case AppLifecycleState.resumed:
        _initializeCamera();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _setErrorState('No cameras available on this device');
        return;
      }
      await _setupCamera(_selectedCameraIndex);
    } catch (e) {
      _setErrorState('Failed to initialize camera: $e');
    }
  }

  void _setErrorState(String message) {
    if (!_isDisposed && mounted) {
      setState(() {
        _errorMessage = message;
        _isInitialized = false;
      });
    }
  }

  Future<void> _setupCamera(int index) async {
    if (_cameras.isEmpty) return;

    // Set state to loading
    if (mounted) {
      setState(() {
        _isInitialized = false;
        _errorMessage = null;
      });
    }

    // Safely dispose previous controller
    await _disposeCamera();

    try {
      final controller = CameraController(
        _cameras[index],
        _resolution,
        enableAudio: true,
        imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
      );

      // Store controller reference
      _controller = controller;

      // Initialize controller
      await controller.initialize();
      if (!mounted || _isDisposed) return;

      // Configure camera settings
      try {
        await Future.wait([
          controller.setFlashMode(_flashMode),
          controller.setFocusMode(FocusMode.auto),
        ]);
      } catch (e) {
        debugPrint('Warning: Could not set initial camera settings: $e');
      }

      // Get zoom range
      try {
        _minZoomLevel = await controller.getMinZoomLevel();
        _maxZoomLevel = await controller.getMaxZoomLevel();
        _currentZoomLevel = _minZoomLevel;
      } catch (e) {
        debugPrint('Warning: Could not get zoom levels: $e');
        _minZoomLevel = 1.0;
        _maxZoomLevel = 1.0;
        _currentZoomLevel = 1.0;
      }

      if (!mounted || _isDisposed) return;
      
      setState(() {
        _selectedCameraIndex = index;
        _isInitialized = true;
      });
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            _setErrorState('Camera access was denied');
            break;
          case 'CameraNotFound':
            _setErrorState('Camera not found');
            break;
          default:
            if (_resolution != ResolutionPreset.low) {
              debugPrint('Retrying with lower resolution');
              setState(() => _resolution = ResolutionPreset.low);
              await _setupCamera(index);
            } else {
              _setErrorState('Failed to initialize camera: ${e.description}');
            }
        }
      } else {
        _setErrorState('Failed to initialize camera: $e');
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    
    setState(() {
      _isInitialized = false;
      _errorMessage = null;
    });
    
    try {
      final newIndex = (_selectedCameraIndex + 1) % _cameras.length;
      await _setupCamera(newIndex);
    } catch (e) {
      _setErrorState('Failed to switch camera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    try {
      FlashMode newMode;
      switch (_flashMode) {
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

      await _controller!.setFlashMode(newMode);
      
      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_recordingDuration >= _maxRecordingDuration) {
        _toggleRecording();
        return;
      }
      setState(() {
        _recordingDuration += const Duration(seconds: 1);
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    setState(() {
      _recordingDuration = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<String> _getVideoSavePath() async {
    if (Platform.isAndroid) {
      // Use the public Pictures directory on Android
      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access external storage');
      }
      
      // Create a custom directory for our app's videos
      final String videoDirectory = path.join(
        directory.path,
        'ReelAI',
        'Videos'
      );
      
      // Create the directory if it doesn't exist
      await Directory(videoDirectory).create(recursive: true);
      
      // Create a unique file name
      final String fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      return path.join(videoDirectory, fileName);
    } else {
      // For other platforms, use the documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String videoDirectory = path.join(appDir.path, 'Videos');
      await Directory(videoDirectory).create(recursive: true);
      final String fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      return path.join(videoDirectory, fileName);
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null) return;

    try {
      if (_isRecording) {
        _stopRecordingTimer();
        final file = await _controller!.stopVideoRecording();
        setState(() => _isRecording = false);
        
        if (mounted) {
          final String? result = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPreviewScreen(
                videoPath: file.path,
              ),
            ),
          );
          
          if (result != null) {
            // Move the temporary file to a permanent location
            final String savePath = await _getVideoSavePath();
            await File(result).copy(savePath);
            await File(result).delete(); // Clean up the temporary file
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Video saved to gallery'),
                  action: SnackBarAction(
                    label: 'View Location',
                    onPressed: () {
                      debugPrint('Video saved to: $savePath');
                      // TODO: Open file location
                    },
                  ),
                ),
              );
            }
          } else {
            // If user cancelled, delete the temporary file
            await File(file.path).delete().catchError((e) => debugPrint('Error deleting temp file: $e'));
          }
        }
      } else {
        final String filePath = await _getVideoSavePath();
        await _controller!.startVideoRecording();
        setState(() => _isRecording = true);
        _startRecordingTimer();
      }
    } catch (e) {
      debugPrint('Error recording video: $e');
      _stopRecordingTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording video: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (_controller == null) return;

    try {
      // Calculate new zoom level
      final double scale = (_baseScaleFactor * details.scale).clamp(
        _minZoomLevel,
        _maxZoomLevel,
      );

      if (scale != _currentZoomLevel) {
        _currentZoomLevel = scale;
        await _controller!.setZoomLevel(scale);
      }
    } catch (e) {
      debugPrint('Error updating zoom: $e');
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScaleFactor = _currentZoomLevel;
  }

  Future<void> _handleTapToFocus(TapDownDetails details) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final box = context.findRenderObject() as RenderBox;
      final point = box.globalToLocal(details.globalPosition);
      
      // Convert tap position to normalized coordinates (0.0 to 1.0)
      final double x = point.dx / box.size.width;
      final double y = point.dy / box.size.height;

      // Set focus point and mode
      await _controller!.setFocusMode(FocusMode.locked);
      await _controller!.setFocusPoint(Offset(x, y));
      await _controller!.setFocusMode(FocusMode.auto);

      // Show focus indicator
      setState(() {
        _focusPoint = point;
      });

      // Hide focus indicator and reset to continuous auto focus after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _focusPoint = null;
        });
        // Reset to continuous auto focus
        await _controller!.setFocusMode(FocusMode.auto);
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

  // Add focus point state
  Offset? _focusPoint;

  IconData _getFlashIcon() {
    switch (_flashMode) {
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

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );
      
      if (video != null && mounted) {
        final String? result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPreviewScreen(
              videoPath: video.path,
            ),
          ),
        );
        
        if (result != null && mounted) {
          // TODO: Handle selected video
          debugPrint('Video selected and confirmed: $result');
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
    }
  }

  Widget _buildErrorWidget() {
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
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializeCamera(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTapDown: _handleTapToFocus,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              child: Center(
                child: CameraPreview(
                  _controller!,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Focus indicator
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
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentZoomLevel.toStringAsFixed(1)}x',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Recording duration indicator
            if (_isRecording)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Camera controls with recording progress
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      color: Colors.white,
                      onPressed: _isRecording ? null : _pickFromGallery,
                    ),
                    
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios),
                      color: Colors.white,
                      onPressed: _isRecording ? null : (_cameras.length < 2 ? null : _switchCamera),
                    ),
                    
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isRecording)
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: _recordingDuration.inSeconds / _maxRecordingDuration.inSeconds,
                              color: Colors.red,
                              backgroundColor: Colors.red.withOpacity(0.2),
                            ),
                          ),
                        IconButton(
                          icon: Icon(
                            _isRecording ? Icons.stop : Icons.fiber_manual_record,
                            size: 50,
                          ),
                          color: _isRecording ? Colors.red : Colors.white,
                          onPressed: _toggleRecording,
                        ),
                      ],
                    ),
                    
                    IconButton(
                      icon: Icon(_getFlashIcon()),
                      color: Colors.white,
                      onPressed: _isRecording ? null : _toggleFlash,
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