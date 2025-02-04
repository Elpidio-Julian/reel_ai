import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/permission_handler_widget.dart';
import '../../services/permission_service.dart';
import '../../routes.dart';

class PermissionTestScreen extends StatefulWidget {
  const PermissionTestScreen({super.key});

  @override
  State<PermissionTestScreen> createState() => _PermissionTestScreenState();
}

class _PermissionTestScreenState extends State<PermissionTestScreen> {
  final PermissionService _permissionService = PermissionService();
  final Map<Permission, String> _permissionStatus = {
    Permission.camera: 'Unknown',
    Permission.microphone: 'Unknown',
    Permission.photos: 'Unknown',
    Permission.videos: 'Unknown',
    Permission.audio: 'Unknown',
  };

  @override
  void initState() {
    super.initState();
    _checkPermissionStatuses();
  }

  Future<void> _checkPermissionStatuses() async {
    final statuses = await _permissionService.checkPermissions();
    setState(() {
      for (final entry in statuses.entries) {
        _permissionStatus[entry.key] = entry.value ? 'Granted' : 'Denied';
      }
    });
  }

  Future<void> _requestSinglePermission(Permission permission) async {
    bool granted = false;
    switch (permission) {
      case Permission.camera:
        granted = await _permissionService.handleCameraPermission();
        break;
      case Permission.microphone:
        granted = await _permissionService.handleMicrophonePermission();
        break;
      case Permission.photos:
      case Permission.videos:
      case Permission.audio:
        granted = await _permissionService.handleStoragePermission();
        break;
      default:
        return;
    }

    setState(() {
      _permissionStatus[permission] = granted ? 'Granted' : 'Denied';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPermissionStatuses,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Individual Permission Tests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._permissionStatus.entries.map(
                  (entry) => Card(
                    child: ListTile(
                      title: Text(_getPermissionTitle(entry.key)),
                      subtitle: Text('Status: ${entry.value}'),
                      trailing: ElevatedButton(
                        onPressed: () => _requestSinglePermission(entry.key),
                        child: const Text('Request'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Combined Permission Test',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                PermissionHandlerWidget(
                  permissions: [
                    Permission.camera,
                    Permission.microphone,
                    Permission.photos,
                    Permission.videos,
                    Permission.audio,
                  ],
                  onPermissionsGranted: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All permissions granted!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _checkPermissionStatuses();
                    
                    // Replace current screen with camera screen
                    Navigator.of(context).pushReplacementNamed(Routes.camera);
                  },
                  child: const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'This area is only visible when all permissions are granted.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => PermissionService.openSettings(),
              child: const Text('Open App Settings'),
            ),
          ),
        ],
      ),
    );
  }

  String _getPermissionTitle(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.microphone:
        return 'Microphone';
      case Permission.photos:
        return 'Photos';
      case Permission.videos:
        return 'Videos';
      case Permission.audio:
        return 'Audio';
      default:
        return permission.toString().split('.').last;
    }
  }
} 