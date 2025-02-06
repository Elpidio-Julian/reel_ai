// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../../services/permission_service.dart';

// class AppSettingsScreen extends StatefulWidget {
//   const AppSettingsScreen({super.key});

//   @override
//   State<AppSettingsScreen> createState() => _AppSettingsScreenState();
// }

// class _AppSettingsScreenState extends State<AppSettingsScreen> {
//   final PermissionService _permissionService = PermissionService();
//   Map<Permission, bool> _permissionStatuses = {};
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPermissions();
//   }

//   Future<void> _loadPermissions() async {
//     setState(() => _isLoading = true);
//     final statuses = await _permissionService.checkPermissions();
//     if (mounted) {
//       setState(() {
//         _permissionStatuses = statuses;
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _handlePermissionTap(Permission permission) async {
//     if (await permission.isPermanentlyDenied) {
//       if (mounted) {
//         final shouldOpenSettings = await showDialog<bool>(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Permission Required'),
//             content: const Text(
//               'This permission is permanently denied. Please enable it in app settings.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Open Settings'),
//               ),
//             ],
//           ),
//         );

//         if (shouldOpenSettings == true) {
//           await openAppSettings();
//           // Refresh permissions after returning from settings
//           await _loadPermissions();
//         }
//       }
//     } else {
//       // Request the permission
//       final status = await permission.request();
//       if (mounted) {
//         setState(() {
//           _permissionStatuses[permission] = status.isGranted;
//         });

//         // Show a snackbar with the result
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               status.isGranted
//                   ? 'Permission granted'
//                   : 'Permission denied',
//             ),
//             backgroundColor: status.isGranted ? Colors.green : Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   String _getPermissionTitle(Permission permission) {
//     switch (permission) {
//       case Permission.camera:
//         return 'Camera';
//       case Permission.microphone:
//         return 'Microphone';
//       case Permission.storage:
//         return 'Storage';
//       case Permission.photos:
//         return 'Photos';
//       case Permission.videos:
//         return 'Videos';
//       default:
//         return permission.toString();
//     }
//   }

//   String _getPermissionDescription(Permission permission) {
//     switch (permission) {
//       case Permission.camera:
//         return 'Required for recording videos';
//       case Permission.microphone:
//         return 'Required for recording audio with videos';
//       case Permission.storage:
//         return 'Required for saving videos';
//       case Permission.photos:
//         return 'Required for accessing your photos';
//       case Permission.videos:
//         return 'Required for accessing your videos';
//       default:
//         return 'Required for app functionality';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('App Settings'),
//       ),
//       body: ListView(
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Text(
//               'Permissions',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           ..._permissionStatuses.entries.map((entry) {
//             final permission = entry.key;
//             final isGranted = entry.value;

//             return ListTile(
//               leading: Icon(
//                 isGranted ? Icons.check_circle : Icons.error_outline,
//                 color: isGranted ? Colors.green : Colors.red,
//               ),
//               title: Text(_getPermissionTitle(permission)),
//               subtitle: Text(_getPermissionDescription(permission)),
//               trailing: TextButton(
//                 onPressed: () => _handlePermissionTap(permission),
//                 child: Text(
//                   isGranted ? 'Enabled' : 'Enable',
//                   style: TextStyle(
//                     color: isGranted ? Colors.green : Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//             );
//           }),

//           const Divider(),

//           // Refresh button
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: ElevatedButton.icon(
//               onPressed: _loadPermissions,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Refresh Permissions'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// } 