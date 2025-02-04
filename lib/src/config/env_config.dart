import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

class EnvConfig {
  static Future<void> load() async {
    await dotenv.dotenv.load(fileName: '.env');
  }

  static String get firebaseAndroidApiKey => 
    dotenv.dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '';

  static String get firebaseAndroidAppId =>
    dotenv.dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '';

  static String get firebaseMessagingSenderId => 
    dotenv.dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  
  static String get firebaseProjectId =>
    dotenv.dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  
  static String get firebaseStorageBucket =>
    dotenv.dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  
  static String get firebaseDatabaseUrl =>
    dotenv.dotenv.env['FIREBASE_DATABASE_URL'] ?? '';
} 