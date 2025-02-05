import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:ui';

enum CameraServiceState {
  uninitialized,
  initializing,
  ready,
  recording,
  error
}

class CameraServiceError implements Exception {
  final String message;
  final String? code;
  
  CameraServiceError(this.message, {this.code});
  
  @override
  String toString() => 'CameraServiceError: $message${code != null ? ' ($code)' : ''}';
}

class CameraService {
  CameraController? _controller;
  CameraServiceState _state = CameraServiceState.uninitialized;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  Timer? _recordingTimer;
  
  // Getters
  CameraServiceState get state => _state;
  CameraController? get controller => _controller;
  bool get isInitialized => _state == CameraServiceState.ready;
  bool get isRecording => _state == CameraServiceState.recording;
  
  // Initialize camera
  Future<void> initialize() async {
    if (_state == CameraServiceState.initializing) return;
    
    try {
      _state = CameraServiceState.initializing;
      
      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraServiceError('No cameras available');
      }
      
      await _setupCamera(_selectedCameraIndex);
      _state = CameraServiceState.ready;
    } catch (e) {
      _state = CameraServiceState.error;
      throw CameraServiceError(
        'Failed to initialize camera: ${e.toString()}',
        code: e is CameraException ? e.code : null
      );
    }
  }
  
  // Setup camera with given index
  Future<void> _setupCamera(int index) async {
    if (_cameras.isEmpty) {
      throw CameraServiceError('No cameras available');
    }

    // Dispose existing controller
    await dispose();
    
    try {
      final controller = CameraController(
        _cameras[index],
        ResolutionPreset.medium,
        enableAudio: true,
      );
      
      _controller = controller;
      await controller.initialize();
      
      // Configure default settings
      await Future.wait([
        controller.setFlashMode(FlashMode.off),
        controller.setFocusMode(FocusMode.auto),
      ]);
      
      _selectedCameraIndex = index;
    } on CameraException catch (e) {
      throw CameraServiceError(
        'Failed to setup camera: ${e.description}',
        code: e.code
      );
    }
  }
  
  // Switch camera
  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    
    final newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCamera(newIndex);
  }
  
  // Start recording
  Future<void> startRecording() async {
    if (!isInitialized || isRecording || _controller == null) {
      throw CameraServiceError('Cannot start recording in current state');
    }
    
    try {
      await _controller!.startVideoRecording();
      _state = CameraServiceState.recording;
    } on CameraException catch (e) {
      throw CameraServiceError(
        'Failed to start recording: ${e.description}',
        code: e.code
      );
    }
  }
  
  // Stop recording
  Future<String> stopRecording() async {
    if (!isRecording || _controller == null) {
      throw CameraServiceError('Not recording');
    }
    
    try {
      final XFile file = await _controller!.stopVideoRecording();
      _state = CameraServiceState.ready;
      return file.path;
    } on CameraException catch (e) {
      throw CameraServiceError(
        'Failed to stop recording: ${e.description}',
        code: e.code
      );
    }
  }
  
  // Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (!isInitialized || _controller == null) return;
    
    try {
      await _controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      debugPrint('Warning: Could not set flash mode: ${e.description}');
    }
  }
  
  // Set focus point
  Future<void> setFocusPoint(Offset point) async {
    if (!isInitialized || _controller == null) return;
    
    try {
      await _controller!.setFocusMode(FocusMode.locked);
      await _controller!.setFocusPoint(point);
      await _controller!.setFocusMode(FocusMode.auto);
    } on CameraException catch (e) {
      debugPrint('Warning: Could not set focus point: ${e.description}');
    }
  }
  
  // Clean up resources
  Future<void> dispose() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    
    if (_controller != null) {
      if (isRecording) {
        try {
          await stopRecording();
        } catch (e) {
          debugPrint('Error stopping recording during dispose: $e');
        }
      }
      
      await _controller!.dispose();
      _controller = null;
    }
    
    _state = CameraServiceState.uninitialized;
  }
} 