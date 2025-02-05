import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager extends StatefulWidget {
  const PermissionManager({super.key});

  @override
  State<PermissionManager> createState() => _PermissionManagerState();
}

class _PermissionManagerState extends State<PermissionManager> {
  Map<Permission, PermissionStatus> _permissionStatus = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
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

    if (mounted) {
      setState(() {});
    }
  }

  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.microphone:
        return 'Microphone';
      case Permission.videos:
        return 'Videos';
      case Permission.photos:
        return 'Photos';
      default:
        return permission.toString();
    }
  }

  IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return Icons.camera_alt;
      case Permission.microphone:
        return Icons.mic;
      case Permission.videos:
        return Icons.video_library;
      case Permission.photos:
        return Icons.photo_library;
      default:
        return Icons.settings;
    }
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

  Future<void> _handlePermissionTap(Permission permission) async {
    final status = await permission.status;

    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${_getPermissionName(permission)} Permission'),
          content: Text(
            'This permission is permanently denied. Would you like to open app settings to enable it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Settings'),
            ),
          ],
        ),
      );

      if (result == true) {
        await openAppSettings();
      }
    } else {
      final newStatus = await permission.request();
      if (mounted) {
        setState(() {
          _permissionStatus[permission] = newStatus;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _permissionStatus.entries.map((entry) {
        final permission = entry.key;
        final status = entry.value;

        return ListTile(
          leading: Icon(_getPermissionIcon(permission)),
          title: Text(_getPermissionName(permission)),
          subtitle: Text(
            _getPermissionStatusText(status),
            style: TextStyle(
              color: status.isGranted ? Colors.green : Colors.red,
            ),
          ),
          trailing: TextButton(
            onPressed: () => _handlePermissionTap(permission),
            child: Text(status.isGranted ? 'Revoke' : 'Grant'),
          ),
        );
      }).toList(),
    );
  }
}
