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
      // 💗 Full-screen background color
      backgroundColor: const Color(0xFFFDEEEE), 

      body: Center(
        child: SizedBox(
          width: 300,        // 👈 CHANGE THIS TO RESIZE LOGO (140–240 recommended)
          child: Image.asset(
            "assets/splash/splash.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
