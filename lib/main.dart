import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'src/routes.dart';
import 'src/views/auth/login_screen.dart';
import 'src/views/auth/register_screen.dart';
import 'src/views/profile/profile_screen.dart';
import 'src/views/camera/camera_recording_screen.dart';
import 'src/views/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'src/config/env_config.dart';
import 'src/providers/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await EnvConfig.load();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: EnvConfig.isProduction 
      ? AndroidProvider.playIntegrity 
      : AndroidProvider.debug,
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'ReelAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        Routes.login: (context) => const LoginScreen(),
        Routes.register: (context) => const RegisterScreen(),
        Routes.profile: (context) => const ProfileScreen(),
        Routes.camera: (context) => const CameraRecordingScreen(),
      },
    );
  }
}
