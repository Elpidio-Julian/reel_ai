import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class CameraService extends StateNotifier<CameraServiceState> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  
  CameraService() : super(CameraServiceState.uninitialized);
  
  // Getters
  CameraController? get controller => _controller;
  
  // Initialize camera
  Future<void> initialize() async {
    if (state == CameraServiceState.initializing) return;
    
    try {
      state = CameraServiceState.initializing;
      
      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraServiceError('No cameras available');
      }
      
      await _setupCamera(_selectedCameraIndex);
      state = CameraServiceState.ready;
    } catch (e) {
      state = CameraServiceState.error;
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
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    
    try {
      final controller = CameraController(
        _cameras[index],
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
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
    if (state != CameraServiceState.ready || _controller == null) {
      throw CameraServiceError('Cannot start recording in current state');
    }
    
    try {
      await _controller!.startVideoRecording();
      state = CameraServiceState.recording;
    } on CameraException catch (e) {
      throw CameraServiceError(
        'Failed to start recording: ${e.description}',
        code: e.code
      );
    }
  }
  
  // Stop recording
  Future<String> stopRecording() async {
    if (state != CameraServiceState.recording || _controller == null) {
      throw CameraServiceError('Not recording');
    }
    
    try {
      final XFile file = await _controller!.stopVideoRecording();
      state = CameraServiceState.ready;
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
    if (state != CameraServiceState.ready || _controller == null) return;
    
    try {
      await _controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      debugPrint('Warning: Could not set flash mode: ${e.description}');
    }
  }
  
  // Set focus point
  Future<void> setFocusPoint(Offset point) async {
    if (state != CameraServiceState.ready || _controller == null) return;
    
    try {
      await _controller!.setFocusMode(FocusMode.locked);
      await _controller!.setFocusPoint(point);
      await _controller!.setFocusMode(FocusMode.auto);
    } on CameraException catch (e) {
      debugPrint('Warning: Could not set focus point: ${e.description}');
    }
  }
  
  @override
  void dispose() {
    if (_controller != null) {
      if (state == CameraServiceState.recording) {
        try {
          stopRecording();
        } catch (e) {
          debugPrint('Error stopping recording during dispose: $e');
        }
      }
      
      _controller!.dispose();
      _controller = null;
    }
    
    state = CameraServiceState.uninitialized;
    super.dispose();
  }
}