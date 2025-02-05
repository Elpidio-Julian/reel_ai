import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';

class PermissionHandlerWidget extends StatefulWidget {
  final Widget child;
  final List<Permission> permissions;
  final VoidCallback onPermissionsGranted;

  const PermissionHandlerWidget({
    super.key,
    required this.child,
    required this.permissions,
    required this.onPermissionsGranted,
  });

  @override
  State<PermissionHandlerWidget> createState() => _PermissionHandlerWidgetState();
}

class _PermissionHandlerWidgetState extends State<PermissionHandlerWidget> {
  final PermissionService _permissionService = PermissionService();
  bool _permissionsChecked = false;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (_permissionsChecked) return;

    final allGranted = await _checkAndRequestPermissions(context);
    
    if (mounted) {
      setState(() {
        _permissionsChecked = true;
        _permissionsGranted = allGranted;
      });

      if (allGranted) {
        widget.onPermissionsGranted();
      }
    }
  }

  Future<bool> _checkAndRequestPermissions(BuildContext context) async {
    final statuses = await _permissionService.checkPermissions();
    
    // Check if any required permission is not granted
    final notGranted = widget.permissions.where((permission) => 
      !statuses[permission]!
    ).toList();

    if (notGranted.isEmpty) {
      return true;
    }

    // Request permissions
    final results = await _permissionService.requestPermissions();
    
    // Check if all permissions are now granted
    final allGranted = widget.permissions.every((permission) => 
      results[permission] ?? false
    );

    if (allGranted) {
      return true;
    }

    // Check if any permission is permanently denied
    final permanentlyDenied = await Future.wait(
      notGranted.map((permission) => 
        _permissionService.isPermanentlyDenied(permission)
      )
    );

    if (permanentlyDenied.contains(true) && context.mounted) {
      // Show dialog to open settings
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'Some permissions are permanently denied. Please enable them in app settings.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await PermissionService.openSettings();
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsChecked) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_permissionsGranted) {
      return widget.child;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Additional permissions are required',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _checkPermissions(),
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
  }
} 