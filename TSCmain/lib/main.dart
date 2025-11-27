import 'package:flutter/material.dart';

// Splash Screen
import 'splash_screen.dart';

// Home Page


// 🔥 Add these imports
import 'home/pages/search_page.dart';
import 'home/pages/love_page.dart';
import 'home/pages/allcategories_page.dart';


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
        
        '/search': (context) => SearchPage(),  // no const
        '/love': (context) => LovePage(),
        '/category/male': (ctx) => CategoryPage(category: 'male'),
        '/category/female': (ctx) =>  CategoryPage(category: 'female'),
        '/category/all': (ctx) =>  CategoryPage(category: 'all'),      // no const
      },
    );
  }
}
