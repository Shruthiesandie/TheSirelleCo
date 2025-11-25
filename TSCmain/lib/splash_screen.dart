import 'package:flutter/material.dart';

class SplashScreenPages extends StatefulWidget {
  const SplashScreenPages({super.key});

  @override
  State<SplashScreenPages> createState() => _SplashScreenPagesState();
}

class _SplashScreenPagesState extends State<SplashScreenPages> {
  @override
  void initState() {
    super.initState();

    // Navigate to Home after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, "/home");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 💗 Soft pastel background
        decoration: const BoxDecoration(
          color: Color(0xFFFFEFEF), // light pink
        ),

        // Center your logo without stretching
        child: Center(
          child: Image.asset(
            "assets/splash/splash.jpg",
            width: MediaQuery.of(context).size.width * 0.55,  // responsive size
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
