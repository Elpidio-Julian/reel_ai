import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check and request camera permission
  Future<bool> handleCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    
    final result = await Permission.camera.request();
    return result.isGranted;
  }

  // Check and request microphone permission
  Future<bool> handleMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  // Check and request legacy storage permission
  Future<bool> _handleLegacyStorage() async {
    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    
    final result = await Permission.storage.request();
    return result.isGranted;
  }

  // Check and request storage permission
  Future<bool> handleStoragePermission() async {
    // For Android 13 and above (API level 33+)
    final modernResults = await [
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ].request();

    final allModernGranted = modernResults.values.every((status) => status.isGranted);
    if (allModernGranted) return true;

    // For older Android versions, try legacy storage permissions
    return _handleLegacyStorage();
  }

  // Handle individual media permissions
  Future<bool> handlePhotosPermission() async {
    final result = await Permission.photos.request();
    if (result.isGranted) return true;
    
    // Try legacy storage permission for older Android versions
    return _handleLegacyStorage();
  }

  Future<bool> handleVideosPermission() async {
    final result = await Permission.videos.request();
    if (result.isGranted) return true;
    
    // Try legacy storage permission for older Android versions
    return _handleLegacyStorage();
  }

  Future<bool> handleAudioPermission() async {
    final result = await Permission.audio.request();
    if (result.isGranted) return true;
    
    // Try legacy storage permission for older Android versions
    return _handleLegacyStorage();
  }

  // Check all required permissions
  Future<Map<Permission, bool>> checkPermissions() async {
    final storageGranted = await Permission.storage.status.isGranted;
    
    return {
      Permission.camera: await Permission.camera.status.isGranted,
      Permission.microphone: await Permission.microphone.status.isGranted,
      Permission.photos: await Permission.photos.status.isGranted || storageGranted,
      Permission.videos: await Permission.videos.status.isGranted || storageGranted,
      Permission.audio: await Permission.audio.status.isGranted || storageGranted,
    };
  }

  // Request all required permissions at once
  Future<Map<Permission, bool>> requestPermissions() async {
    // Try modern permissions first
    await [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ].request();

    // Try legacy storage as fallback
    await _handleLegacyStorage();

    return checkPermissions();
  }

  // Check if permission is permanently denied
  Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  // Open app settings
  static Future<bool> openSettings() {
    return openAppSettings();
  }

  Future<bool> requestCameraPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    return camera.isGranted && microphone.isGranted;
  }

  Future<bool> requestStoragePermissions() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    
    // For Android 10 and above
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }
    
    return false;
  }

  Future<bool> checkCameraPermissions() async {
    final camera = await Permission.camera.status;
    final microphone = await Permission.microphone.status;
    return camera.isGranted && microphone.isGranted;
  }

  Future<bool> checkStoragePermissions() async {
    final storage = await Permission.storage.status;
    final manageStorage = await Permission.manageExternalStorage.status;
    return storage.isGranted || manageStorage.isGranted;
  }

  Future<void> openPermissionSettings() async {
    await openAppSettings();
  }
} 