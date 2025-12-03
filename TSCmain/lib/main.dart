import 'package:flutter/material.dart';
import 'splash/splash_screen.dart';

// Pages
import 'home/home_page.dart';
import 'pages/membership_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_page.dart';
import 'pages/love_page.dart';
import 'pages/allcategories_page.dart';
import 'pages/login_page.dart';
import 'pages/create_account_page.dart';
import 'pages/username_page.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// ⭐ Splash loader remains your home launcher
      home: const SplashScreen(),

      /// ⭐ Your full routing system preserved
      routes: {
        "/home": (_) => const HomePage(),
        "/membership": (_) => const MembershipPage(),
        "/cart": (_) => const CartPage(),
        "/profile": (_) => const ProfilePage(),
        "/search": (_) => const SearchPage(),
        "/love": (_) => const LovePage(),
        "/categories": (_) => const AllCategoriesPage(),
        "/login": (_) => LoginPage(),
        "/register": (_) => const CreateAccountPage(),
        "/username": (_) => const UsernamePage(),
      },
    );
  }
}
