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

        // Background matches your image color
        color: const Color(0xFFFCE4EC), // light baby pink

        child: Image.asset(
          "assets/splash/splash.png",
          fit: BoxFit.contain,   // shows the full image without cutting
        ),
      ),
    );
  }
}
