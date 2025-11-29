// lib/pages/login_page.dart
//
// Full, ready-to-paste login page that uses your Rive state machine
// (State Machine 1) and inputs found in your screenshot:
//
// Inputs used:
//   - isFocus      (Bool)
//   - isPassword   (Bool)
//   - login_success (Trigger)
//   - login_fail    (Trigger)
//   - eye_track     (Number)  <-- optional, we'll update it as the user types
//
// Rive file assumed at: assets/animations/login_character.riv
// Make sure pubspec.yaml includes that asset and rive dependency.
//
// Keeps the same aesthetic as your previous version and:
//  - fires login_success/login_fail triggers on attempts
//  - toggles isFocus & isPassword based on text field focus
//  - sets eye_track number while typing (small demo)
//  - navigates to "/home" on success

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Rive
  Artboard? _riveArtboard;
  StateMachineController? _controller;

  // State machine inputs (we'll wire these after controller is created)
  late SMITrigger _successTrigger;
  late SMITrigger _failTrigger;
  late SMIBool _isFocus;
  late SMIBool _isPassword;
  SMINumber? _eyeTrack; // optional

  // Text controllers & focus nodes
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  // Generated test credentials
  late String _testUsername;
  late String _testPassword;

  @override
  void initState() {
    super.initState();
    _generateTestCredentials();
    _loadRive();

    // focus listeners to toggle isFocus/isPassword
    _userFocus.addListener(() {
      if (_isFocus != null) {
        // if controller not ready yet, ignore
        try {
          _isFocus.value = _userFocus.hasFocus || _passFocus.hasFocus;
        } catch (_) {}
      }
      // also set eye_track to center when not typing
      _updateEyeTrack();
    });

    _passFocus.addListener(() {
      if (_isFocus != null && _isPassword != null) {
        try {
          _isFocus.value = _userFocus.hasFocus || _passFocus.hasFocus;
          _isPassword.value = _passFocus.hasFocus;
        } catch (_) {}
      }
      _updateEyeTrack();
    });

    // while typing update the eye track (small demo to make bird look)
    _userCtrl.addListener(() => _updateEyeTrackFromText(_userCtrl.text));
    _passCtrl.addListener(() => _updateEyeTrackFromText(_passCtrl.text));
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _generateTestCredentials() {
    final rnd = Random();
    final u = "user${rnd.nextInt(900) + 100}"; // e.g. user564
    final p = "${rnd.nextInt(9000) + 1000}"; // 4-digit like 6106
    _testUsername = u;
    _testPassword = p;
  }

  Future<void> _loadRive() async {
    try {
      final data = await rootBundle.load('assets/animations/login_character.riv');
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;

      // create controller for the state machine named exactly "State Machine 1"
      final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
      if (controller == null) {
        // State machine not found — fall back to idle display
        artboard.addController(SimpleAnimation('idle'));
        setState(() => _riveArtboard = artboard);
        return;
      }

      artboard.addController(controller);
      // find inputs
      // wrap each find with try/catch; if a name differs the app won't crash
      try {
        _isFocus = controller.findInput('isFocus') as SMIBool;
      } catch (_) {
        // create dummy if not found (prevents null errors)
        _isFocus = SMIBool(false);
      }
      try {
        _isPassword = controller.findInput('isPassword') as SMIBool;
      } catch (_) {
        _isPassword = SMIBool(false);
      }
      try {
        _successTrigger = controller.findInput('login_success') as SMITrigger;
      } catch (_) {
        // fallback dummy
        _successTrigger = SMITrigger();
      }
      try {
        _failTrigger = controller.findInput('login_fail') as SMITrigger;
      } catch (_) {
        _failTrigger = SMITrigger();
      }
      try {
        _eyeTrack = controller.findInput('eye_track') as SMINumber;
      } catch (_) {
        _eyeTrack = null;
      }

      // initialize focus booleans to current focus state
      _isFocus.value = _userFocus.hasFocus || _passFocus.hasFocus;
      _isPassword.value = _passFocus.hasFocus;

      setState(() {
        _riveArtboard = artboard;
        _controller = controller;
      });
    } catch (e) {
      debugPrint('Rive load error: $e');
      // not fatal — keep UI usable
    }
  }

  // Small helper: update eye track from typing length (demo)
  void _updateEyeTrackFromText(String text) {
    if (_eyeTrack == null) return;
    // map text length to [-20..20] for example
    final len = text.length.clamp(0, 20);
    final value = (len / 20.0) * 40 - 20; // [-20..20]
    try {
      _eyeTrack!.value = value;
    } catch (_) {}
  }

  void _updateEyeTrack() {
    if (_eyeTrack == null) return;
    try {
      _eyeTrack!.value = 0;
    } catch (_) {}
  }

  // Called when user presses Login
  void _attemptLogin() {
    final inputUser = _userCtrl.text.trim();
    final inputPass = _passCtrl.text.trim();

    // micro delay so user can see reaction
    if (inputUser == _testUsername && inputPass == _testPassword) {
      // success
      try {
        _successTrigger.fire();
      } catch (_) {}
      // wait a bit to let animation play then navigate
      Future.delayed(const Duration(milliseconds: 900), () {
        // navigate to home (replace)
        if (mounted) Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      // fail
      try {
        _failTrigger.fire();
      } catch (_) {}
      // also show small message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect credentials')),
      );
    }
  }

  // Rive widget area
  Widget _riveArea() {
    if (_riveArtboard == null) {
      // placeholder circle
      return SizedBox(
        height: 220,
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(80),
              boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 10)],
            ),
            child: const Icon(Icons.person, size: 64, color: Colors.pinkAccent),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: Rive(
        artboard: _riveArtboard!,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // keep existing logo
              Image.asset('assets/logo/logo.png', height: 60),

              const SizedBox(height: 8),
              // Rive artboard
              _riveArea(),
              const SizedBox(height: 12),

              // Test credentials card (for quick test)
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.pinkAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Test credentials — username: $_testUsername  password: $_testPassword",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '$_testUsername:$_testPassword'));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied credentials')));
                        },
                        child: const Text("Copy"),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Username
              TextField(
                controller: _userCtrl,
                focusNode: _userFocus,
                decoration: InputDecoration(
                  hintText: "Username",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _passFocus.requestFocus(),
              ),

              const SizedBox(height: 12),

              // Password
              TextField(
                controller: _passCtrl,
                focusNode: _passFocus,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _attemptLogin(),
              ),

              const SizedBox(height: 18),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _attemptLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // placeholder for create account
                },
                child: const Text("Create an account", style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
