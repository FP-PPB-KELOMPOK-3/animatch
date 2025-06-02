import 'package:animatch/firebase_options.dart';
import 'package:animatch/screens/home.screen.dart';
import 'package:animatch/Auth/login.dart';
import 'package:animatch/Auth/register.dart';
import 'package:animatch/screens/account_detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniMatch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
            initialRoute: 'login',
      routes: {
        'home': (context) => const HomeScreen(title: 'AniMatch'),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
        'account_detail': (context) => const AccountDetail(),
      },
    );
  }
}
