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

  // Animations (direct control)
  RiveAnimationController? introAnim;
  RiveAnimationController? idleAnim;
  RiveAnimationController? lookLeft;
  RiveAnimationController? eyeCover;
  RiveAnimationController? successAnim;
  RiveAnimationController? failAnim;

  final _email = TextEditingController();
  final _password = TextEditingController();

  late String _testUser;
  late String _testPass;

  bool _isEyeCovered = false;

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

  void _loadRive() async {
    final data = await rootBundle.load("assets/animation/login_character.riv");
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    // Match EXACT animation names from your screenshot
    introAnim = SimpleAnimation("Intro", autoplay: true);
    idleAnim = SimpleAnimation("look_idle");
    lookLeft = SimpleAnimation("look_left", autoplay: false);
    eyeCover = SimpleAnimation("eye_cover", autoplay: false);
    successAnim = SimpleAnimation("success", autoplay: false);
    failAnim = SimpleAnimation("fail", autoplay: false);

    // Play intro first
    artboard.addController(introAnim!);

    // When intro finishes → switch to idle
    introAnim!.isActiveChanged.addListener(() {
      if (!introAnim!.isActive) {
        artboard.addController(idleAnim!);
      }
    });

    setState(() => _artboard = artboard);
  }

  // Helper: force play vibration controller
  void play(RiveAnimationController? cont) {
    if (cont == null || _artboard == null) return;
    cont.isActive = false;
    _artboard!.addController(cont);
    cont.isActive = true;
  }

  // ---------------- LOGIN LOGIC ----------------
  void _attemptLogin() {
    idleAnim?.isActive = false;

    if (_email.text.trim() == _testUser &&
        _password.text.trim() == _testPass) {
      play(successAnim);
      Future.delayed(const Duration(milliseconds: 900), () {
        Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      play(failAnim);
    }

    Future.delayed(const Duration(seconds: 2), () {
      play(idleAnim);
    });
  }

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
                              Clipboard.setData(
                                ClipboardData(
                                    text: "$_testUser:$_testPass"),
                              );
                            },
                            child: const Text("Copy"),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // USERNAME
                  TextField(
                    controller: _email,
                    onTap: () {
                      _isEyeCovered = false;
                    },
                    onChanged: (value) {
                      if (!_isEyeCovered) {
                        play(lookLeft);
                      }
                    },
                    decoration: _box("Username"),
                  ),

                  const SizedBox(height: 14),

                  // PASSWORD
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onTap: () {
                      _isEyeCovered = true;
                      play(eyeCover);
                    },
                    onChanged: (v) {
                      _isEyeCovered = true;
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

                  const SizedBox(height: 180),
                ],
              ),
            ),
          ),

          // RIVE BUNNY
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 280,
              child: _artboard == null
                  ? const CircularProgressIndicator()
                  : Rive(artboard: _artboard!, fit: BoxFit.contain),
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
