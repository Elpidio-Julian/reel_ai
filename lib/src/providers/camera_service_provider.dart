import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/camera_service.dart';

final cameraServiceProvider = StateNotifierProvider<CameraService, CameraServiceState>((ref) {
  final service = CameraService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
