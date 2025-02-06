import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../routes.dart';
import '../../../providers/auth_state.dart';
import '../../../widgets/loading_overlay.dart';
import '../widgets/gallery_tab.dart';
import '../widgets/editor_tab.dart';
import '../widgets/publish_tab.dart';
import '../widgets/profile_tab.dart';
import '../widgets/upload_tab.dart';

// Selected tab index provider
final selectedTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _handleAuthStateChange(BuildContext context, AsyncValue<dynamic> state) {
    state.whenOrNull(
      data: (user) {
        if (user == null && context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
          );
        }
      },
      error: (error, stackTrace) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication error: $error'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes
    ref.listen<AsyncValue>(
      authStateProvider,
      (_, next) => _handleAuthStateChange(context, next),
    );

    // Watch auth state for UI
    final authState = ref.watch(authStateProvider);
    final selectedIndex = ref.watch(selectedTabProvider);
    
    final tabWidgets = [
      const UploadTab(),
      const GalleryTab(),
      const EditorTab(),
      const PublishTab(),
      const ProfileTab(),
    ];

    return authState.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink(); // Will be redirected by the listener
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('ReelAI'),
          ),
          body: IndexedStack(
            index: selectedIndex,
            children: tabWidgets,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Create',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_library),
                label: 'Gallery',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                label: 'Editor',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.publish),
                label: 'Publish',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: selectedIndex,
            onTap: (index) => ref.read(selectedTabProvider.notifier).state = index,
          ),
        );
      },
      loading: () => const LoadingOverlay(),
      error: (error, stackTrace) => const SizedBox.shrink(), // Will be handled by listener
    );
  }
} 