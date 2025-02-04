import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:flutter/foundation.dart';

class EnvConfig {
  static Future<void> load() async {
    try {
      await dotenv.dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Warning: .env file not found. Using default values for development.');
    }
  }

  static String get firebaseAndroidApiKey => 
    dotenv.dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? 'AIzaSyBZi_spK0RohOfKuyoOfq5PhBIkNCEfN-A';

  static String get firebaseAndroidAppId =>
    dotenv.dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '1:101842051057:android:7ae75d1ced8ee1ddd5ae50';

  static String get firebaseMessagingSenderId => 
    dotenv.dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '101842051057';
  
  static String get firebaseProjectId =>
    dotenv.dotenv.env['FIREBASE_PROJECT_ID'] ?? 'reel-ai-424c6';
  
  static String get firebaseStorageBucket =>
    dotenv.dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'reel-ai-424c6.firebasestorage.app';
  
  static String get firebaseDatabaseUrl =>
    dotenv.dotenv.env['FIREBASE_DATABASE_URL'] ?? 'https://reel-ai-424c6-default-rtdb.firebaseio.com';
} 