import 'package:flutter/material.dart';
import 'splash/splash_screen.dart';
import 'home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const SplashScreen(),

      routes: {
        "/home": (_) => const HomePage(),
      },
    );
  }
}
