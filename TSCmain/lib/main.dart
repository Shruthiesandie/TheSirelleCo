import 'package:flutter/material.dart';

import 'splash_screen.dart';   // 👈 Your splash file in lib/


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Start app with splash screen
      home: const SplashScreenPages(),

      // All navigation routes
      routes: {
        '/home': (context) =>  HomePage(),
      },
    );
  }
}
