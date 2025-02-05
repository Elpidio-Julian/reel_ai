import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes.dart';
import '../../providers/auth_state.dart';
import '../settings/app_settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileOptionsScreen extends ConsumerWidget {
  const ProfileOptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

          const Divider(),

          // Account Settings
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () {
              // TODO: Implement notifications settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon: Notifications')),
              );
            },
          ),

          const Divider(),

          // App Settings
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('App Settings'),
            subtitle: const Text('Permissions, storage, and more'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppSettingsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              // TODO: Implement help & support
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon: Help & Support')),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              // TODO: Implement about screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon: About')),
              );
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await ref.read(authStateProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, Routes.login);
                }
              }
            },
          ),

          const SizedBox(height: 32), // Bottom padding
        ],
      ),
    );
  }
} 