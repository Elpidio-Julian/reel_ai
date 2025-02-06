import 'package:flutter/material.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/screens/home_screen.dart';
import 'views/camera/camera_recording_screen.dart';
import 'views/profile/edit_profile_screen.dart';

class Routes {
  // Auth Flow
  static const String login = '/login';
  static const String register = '/register';
  
  // Main App
  static const String home = '/home';
  
  // Full Screen Features
  static const String camera = '/camera';
  static const String editProfile = '/edit-profile';

  // Prevent instantiation
  Routes._();

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Auth Flow
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      
      // Main App
      home: (context) => const HomeScreen(),
      
      // Full Screen Features
      camera: (context) => const CameraRecordingScreen(),
      editProfile: (context) => const EditProfileScreen(),
    };
  }
}