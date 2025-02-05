import 'package:flutter/material.dart';
import '../../routes.dart';
import 'profile_options_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  // Titles for bottom navigation items (for reference)
  static const List<String> _titles = [
    'Camera/Upload',
    'Gallery',
    'Editor',
    'Publish',
    'Profile Options',
  ];

  // Placeholder widget for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Camera/Upload Placeholder')),
    Center(child: Text('Video Gallery Placeholder')),
    Center(child: Text('Video Editor Placeholder')),
    Center(child: Text('Publish Videos Placeholder')),
    ProfileOptionsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          // Placeholder for creator's video list or content
          Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
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
            label: 'Options',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
} 