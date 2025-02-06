import 'package:flutter/material.dart';
import '../../../routes.dart';
import '../widgets/gallery_tab.dart';
import '../widgets/editor_tab.dart';
import '../widgets/publish_tab.dart';
import '../widgets/profile_tab.dart';
import '../widgets/upload_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabWidgets = [
    const UploadTab(),
    const GalleryTab(),
    const EditorTab(),
    const PublishTab(),
    const ProfileTab(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReelAI'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabWidgets,
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
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
} 