import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/permission_service.dart';
import '../../routes.dart';

class PermissionTestScreen extends StatefulWidget {
  const PermissionTestScreen({super.key});

  @override
  State<PermissionTestScreen> createState() => _PermissionTestScreenState();
}

class _PermissionTestScreenState extends State<PermissionTestScreen> {
  final PermissionService _permissionService = PermissionService();
  Map<Permission, bool> _permissionStatuses = {};
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatuses();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _checkPermissionStatuses() async {
    final statuses = await _permissionService.checkPermissions();
    if (!_isDisposed && mounted) {
      setState(() {
        _permissionStatuses = statuses;
      });
    }
  }

  Future<void> _requestPermissions() async {
    await _permissionService.requestPermissions();
    await _checkPermissionStatuses();
  }

  bool get _allPermissionsGranted => 
    _permissionStatuses.isNotEmpty && 
    _permissionStatuses.values.every((granted) => granted);

  void _navigateToCamera() {
    Navigator.pushReplacementNamed(context, Routes.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Test'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: _permissionStatuses.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key.toString()),
                  trailing: Icon(
                    entry.value ? Icons.check_circle : Icons.error,
                    color: entry.value ? Colors.green : Colors.red,
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (!_allPermissionsGranted)
                  ElevatedButton(
                    onPressed: _requestPermissions,
                    child: const Text('Request Permissions'),
                  )
                else
                  ElevatedButton(
                    onPressed: _navigateToCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Continue to Camera'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 