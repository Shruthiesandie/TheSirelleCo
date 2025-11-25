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
      backgroundColor: Colors.white, // set theme background

      body: Center(
        child: Image.asset(
          "assets/splash/splash.png",   // 👈 your logo file
          width: 260,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
