import 'package:flutter/material.dart';

// Splash Screen
import 'splash_screen.dart';

// Home Page
import 'home/pages/home_page.dart';

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
        '/home': (context) => const HomePage(),
        '/search': (context) => const SearchPage(),
        '/favourites': (context) => const LovePage(),
      },
    );
  }
}
