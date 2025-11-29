import 'dart:async';
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
  Artboard? _artboard;

  // Rive state machine controller + triggers
  StateMachineController? controller;

  SMITrigger? trigIntro;
  SMITrigger? trigIdle;
  SMITrigger? trigLookLeft;
  SMITrigger? trigLookRight;
  SMITrigger? trigEyeCover;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;

  Timer? _idleTimer;

  final _email = TextEditingController();
  final _password = TextEditingController();

  late String _testUser;
  late String _testPass;

  bool _isInPassword = false;

  @override
  void initState() {
    super.initState();
    _generateCredentials();
    _loadRive();
  }

  void _generateCredentials() {
    final r = Random();
    _testUser = "user${r.nextInt(900) + 100}";
    _testPass = (r.nextInt(9000) + 1000).toString();
  }

  // ---------------- RIVE LOAD ----------------
  void _loadRive() async {
    final data =
        await rootBundle.load("assets/animation/login_character.riv");
    final file = RiveFile.import(data);
    final art = file.mainArtboard;

    // Load state machine
    controller =
        StateMachineController.fromArtboard(art, "State Machine 1");

    if (controller != null) {
      art.addController(controller!);

      trigIntro =
          controller!.findInput<bool>("trigger_intro") as SMITrigger?;
      trigIdle =
          controller!.findInput<bool>("trigger_idle") as SMITrigger?;
      trigLookLeft = controller!
          .findInput<bool>("trigger_look_left") as SMITrigger?;
      trigLookRight = controller!
          .findInput<bool>("trigger_look_right") as SMITrigger?;
      trigEyeCover = controller!
          .findInput<bool>("trigger_eye_cover") as SMITrigger?;
      trigSuccess =
          controller!.findInput<bool>("trigger_success") as SMITrigger?;
      trigFail =
          controller!.findInput<bool>("trigger_fail") as SMITrigger?;
    }

    setState(() => _artboard = art);

    // Start intro animation
    trigIntro?.fire();

    _startIdleTimer();
  }

  // ---------------- ANIMATION HELPER ----------------
  void _play(SMITrigger? trig) {
    trig?.fire();
  }

  // ---------------- IDLE TIMER ----------------
  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 5), () {
      if (!_isInPassword) {
        _play(trigIdle);
      }
    });
  }

  // ---------------- LOGIN LOGIC ----------------
  void _attemptLogin() {
    _idleTimer?.cancel();

    final username = _email.text.trim();
    final password = _password.text.trim();

    if (username == _testUser && password == _testPass) {
      _play(trigSuccess);

      Future.delayed(const Duration(milliseconds: 900), () {
        Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      _play(trigFail);

      Future.delayed(const Duration(seconds: 2), () {
        _play(trigIdle);
      });
    }
  }

  // ---------------- BUILD UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset("assets/logo/logo.png", height: 60),
                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.pink),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                "username: $_testUser   password: $_testPass"),
                          ),
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: "$_testUser:$_testPass"));
                            },
                            child: const Text("Copy"),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // USERNAME FIELD
                  TextField(
                    controller: _email,
                    onTap: () {
                      _isInPassword = false;
                      _play(trigIdle);
                      _startIdleTimer();
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (value.length % 2 == 0) {
                          _play(trigLookLeft);
                        } else {
                          _play(trigLookRight);
                        }
                      }
                      _startIdleTimer();
                    },
                    decoration: _box("Username"),
                  ),

                  const SizedBox(height: 14),

                  // PASSWORD FIELD
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onTap: () {
                      _isInPassword = true;
                      _play(trigEyeCover);
                      _startIdleTimer();
                    },
                    onChanged: (_) {
                      _isInPassword = true;
                      _play(trigEyeCover);
                      _startIdleTimer();
                    },
                    decoration: _box("Password"),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _attemptLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style:
                            TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),

          // RIVE CHARACTER
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 260,
              child: _artboard == null
                  ? const Center(child: CircularProgressIndicator())
                  : Rive(
                      artboard: _artboard!,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _box(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
