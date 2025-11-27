import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, "/home");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9E1D9), // 🌸 Your color
      body: Center(
        child: Image.asset(
          "assets/splash/splash.png",
          width: 450,   // increased size
          height: 450,  // increased size
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
