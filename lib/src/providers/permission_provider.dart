import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission_provider.freezed.dart';
part 'permission_provider.g.dart';

/// Android permission groups based on protection levels
/// https://developer.android.com/guide/topics/permissions/overview
enum PermissionGroup {
  /// Dangerous permissions - require explicit user approval
  camera,
  microphone,
  storage,
  /// Normal permissions - automatically granted
  internet,
  /// Special permissions - require special handling
  systemAlertWindow,
  /// Runtime permissions - Android 13+ specific
  notifications,
  photos,
  videos,
}

@freezed
class PermissionState with _$PermissionState {
  const factory PermissionState({
    required Map<Permission, PermissionStatus> permissions,
    required bool isLoading,
    String? error,
  }) = _PermissionState;
}

@riverpod
class PermissionNotifier extends _$PermissionNotifier {
  @override
  Future<PermissionState> build() async {
    // Android runtime permissions to check
    final permissions = [
      Permission.camera,        // Dangerous permission
      Permission.microphone,    // Dangerous permission
      Permission.storage,       // Legacy storage permission
      Permission.photos,        // Android 13+ specific
      Permission.videos,        // Android 13+ specific
      Permission.notification,  // Android 13+ specific
    ];
    
    try {
      // Get initial statuses
      final statuses = await Future.wait(
        permissions.map((p) => p.status),
      );
      
      return PermissionState(
        permissions: Map.fromIterables(permissions, statuses),
        isLoading: false,
      );
    } catch (e) {
      return PermissionState(
        permissions: {},
        isLoading: false,
        error: 'Failed to initialize permissions: $e',
      );
    }
  }

  /// Request a specific runtime permission following Android patterns
  Future<void> requestPermission(Permission permission) async {
    state = const AsyncLoading();
    
    try {
      // Check if permission is already granted
      final status = await permission.status;
      if (status.isGranted) {
        _updatePermissionState(permission, status);
        return;
      }

      // Show rationale if needed (user previously denied)
      if (status.isDenied && !status.isPermanentlyDenied) {
        // This would be handled by the UI layer
        // The UI can show a rationale dialog before proceeding
      }

      // Request the permission
      final result = await permission.request();
      
      // Update state with new status
      _updatePermissionState(permission, result);
      
    } catch (e) {
      state = AsyncError(
        'Failed to request permission: $e',
        StackTrace.current,
      );
    }
  }

  /// Request multiple permissions at once (Android pattern)
  Future<void> requestPermissions(List<Permission> permissions) async {
    state = const AsyncLoading();
    
    try {
      // Request all permissions
      final results = await permissions.request();
      
      // Update state with new statuses
      state = AsyncData(PermissionState(
        permissions: results,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncError(
        'Failed to request permissions: $e',
        StackTrace.current,
      );
    }
  }

  /// Open app settings for permanently denied permissions
  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      state = AsyncError(
        'Failed to open settings: $e',
        StackTrace.current,
      );
    }
  }

  /// Helper to update state for a single permission
  void _updatePermissionState(Permission permission, PermissionStatus status) {
    if (!state.isLoading && state.hasValue) {
      final updatedPermissions = Map<Permission, PermissionStatus>.from(
        state.value!.permissions,
      )..update(permission, (_) => status);
      
      state = AsyncData(PermissionState(
        permissions: updatedPermissions,
        isLoading: false,
      ));
    }
  }
} 