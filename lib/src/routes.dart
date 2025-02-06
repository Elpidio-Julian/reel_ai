import 'package:flutter/material.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/camera/camera_recording_screen.dart';
import 'views/upload/video_upload_screen.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String camera = '/camera';
  static const String upload = '/upload';

  // Prevent instantiation
  Routes._();

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      profile: (context) => const ProfileScreen(),
      camera: (context) => const CameraRecordingScreen(),
      upload: (context) => const VideoUploadScreen(),
    };
  }
}