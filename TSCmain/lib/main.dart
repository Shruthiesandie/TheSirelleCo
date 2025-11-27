import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/splash_screen.dart'; // If you have one

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Start at Splash Screen
      home: const SplashScreen(),

      // Declare all routes here
      routes: {
        "/home": (_) =>  HomePage(),
        "/category/male": (_) =>  CategoryMalePage(),
        "/category/female": (_) =>  CategoryFemalePage(),
        "/category/unisex": (_) =>  CategoryUnisexPage(),
        "/search": (_) =>  SearchPage(),
        "/love": (_) =>  LovePage(),
      },
    );
  }
}
