import 'package:animatch/firebase_options.dart';
import 'package:animatch/Auth/login.dart';
import 'package:animatch/Auth/register.dart';
import 'package:animatch/screens/match.screen.dart';
import 'package:animatch/screens/match_list.screen.dart';
import 'package:animatch/screens/account_detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        'home': (context) => const MatchScreen(),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
        'account_detail': (context) => const AccountDetail(),
        'match_list': (context) => const MatchesListScreen(),
      },
    );
  }
}
