import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionState {
  final bool cameraPermissionGranted;
  final bool microphonePermissionGranted;
  final bool storagePermissionGranted;

  const PermissionState({
    this.cameraPermissionGranted = false,
    this.microphonePermissionGranted = false,
    this.storagePermissionGranted = false,
  });

  PermissionState copyWith({
    bool? cameraPermissionGranted,
    bool? microphonePermissionGranted,
    bool? storagePermissionGranted,
  }) {
    return PermissionState(
      cameraPermissionGranted: cameraPermissionGranted ?? this.cameraPermissionGranted,
      microphonePermissionGranted: microphonePermissionGranted ?? this.microphonePermissionGranted,
      storagePermissionGranted: storagePermissionGranted ?? this.storagePermissionGranted,
    );
  }

  bool get allPermissionsGranted =>
      cameraPermissionGranted && microphonePermissionGranted && storagePermissionGranted;
}

class PermissionController extends StateNotifier<PermissionState> {
  PermissionController() : super(const PermissionState()) {
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final camera = await Permission.camera.status;
    final microphone = await Permission.microphone.status;
    final storage = await Permission.storage.status;

    state = state.copyWith(
      cameraPermissionGranted: camera.isGranted,
      microphonePermissionGranted: microphone.isGranted,
      storagePermissionGranted: storage.isGranted,
    );
  }

  Future<bool> requestPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    final storage = await Permission.storage.request();

    state = state.copyWith(
      cameraPermissionGranted: camera.isGranted,
      microphonePermissionGranted: microphone.isGranted,
      storagePermissionGranted: storage.isGranted,
    );

    return state.allPermissionsGranted;
  }
}

final permissionControllerProvider =
    StateNotifierProvider<PermissionController, PermissionState>((ref) {
  return PermissionController();
});
