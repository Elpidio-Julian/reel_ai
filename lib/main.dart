import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/providers/auth_provider.dart';
import 'src/utils/routes.dart';
import 'src/views/auth/login_screen.dart';
import 'src/views/auth/register_screen.dart';
import 'src/views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'ReelAI',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: Routes.login,
        routes: {
          Routes.login: (context) => const LoginScreen(),
          Routes.register: (context) => const RegisterScreen(),
          Routes.home: (context) => const HomeScreen(),
        },
      ),
    );
  }
}
