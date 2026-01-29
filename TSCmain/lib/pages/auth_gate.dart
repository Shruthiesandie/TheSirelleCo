import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/login_page.dart';
import '../home/home_page.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/cart_controllers.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate>
    with WidgetsBindingObserver {
  static const _maxInactiveDays = 15;
  static const _lastActiveKey = 'last_active_time';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Update activity time when app resumes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateLastActive();
    }
  }

  Future<bool> _isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveMillis = prefs.getInt(_lastActiveKey);

    if (lastActiveMillis == null) return false;

    final lastActive =
        DateTime.fromMillisecondsSinceEpoch(lastActiveMillis);
    final now = DateTime.now();

    return now.difference(lastActive).inDays >= _maxInactiveDays;
  }

  Future<void> _updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastActiveKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _forceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await FirebaseAuth.instance.signOut();
    await prefs.remove(_lastActiveKey);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While Firebase is resolving auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Not logged in
        if (user == null) {
          return const LoginPage();
        }

        // Logged in → check inactivity
        return FutureBuilder<bool>(
          future: _isSessionExpired(),
          builder: (context, sessionSnap) {
            if (!sessionSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Session expired → logout
            if (sessionSnap.data == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
                await _forceLogout();
              });
              return const LoginPage();
            }

            // Valid session
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              await _updateLastActive();
              await FavoritesController.loadForCurrentUser();
              await CartController.loadForCurrentUser();
            });
            return const HomePage();
          },
        );
      },
    );
  }
}