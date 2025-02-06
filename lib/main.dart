import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'src/routes.dart';
import 'src/views/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'src/config/env_config.dart';

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
    return MaterialApp(
      title: 'ReelAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: Routes.getRoutes(),
    );
  }
}
