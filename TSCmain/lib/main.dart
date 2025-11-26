import 'package:flutter/material.dart';

// Splash Screen
import 'splash_screen.dart';

// Home Page
import 'home/pages/home_page.dart';

// 🔥 Add these imports
import 'home/pages/search_page.dart';
import 'home/pages/love_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Start app with your custom splash
      home: const SplashScreenPages(),

      // Navigation routes
      routes: {
        '/home': (context) => HomePage(),
        '/search': (context) => SearchPage(),  // no const
        '/love': (context) => LovePage(),      // no const
      },
    );
  }
}
