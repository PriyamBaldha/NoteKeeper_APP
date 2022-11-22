import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/Splash_screen.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'SplashScreen',
    routes: {
      'SplashScreen': (context) => const SplashScreen(),
      'HomePage': (context) => const HomePage(),
    },
  ));
}
