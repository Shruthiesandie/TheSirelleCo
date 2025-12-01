import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // ✨ Fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // ⏳ After 2 sec → go to LOGIN PAGE
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 38, 91), // 🌸 Light pink
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Image.asset(
              "assets/splash/splash.png",
              width: 450,
              height: 450,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
