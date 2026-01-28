// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../pages/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  bool _navigated = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateOnce();
    });
  }

  void _navigateOnce() {
    if (_navigated || !mounted) return;
    _navigated = true;

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
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
      backgroundColor: const Color.fromARGB(255, 252, 235, 241), // 🌸 Light pink
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Image.asset(
              "assets/splash/splash.png",
              width: 600,
              height: 600,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
