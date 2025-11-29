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

  // Animations
  late SimpleAnimation intro;
  late SimpleAnimation idleLook;
  late SimpleAnimation eyeCover;
  late SimpleAnimation lookLeft;
  late SimpleAnimation lookRight;
  late SimpleAnimation successAnim;
  late SimpleAnimation failAnim;

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
    final data = await rootBundle.load("assets/animation/login_character.riv");
    final file = RiveFile.import(data);
    final art = file.mainArtboard;

    intro = SimpleAnimation("Intro", autoplay: false);
    idleLook = SimpleAnimation("idle_look_around", autoplay: false);
    eyeCover = SimpleAnimation("eye_cover", autoplay: false);
    lookLeft = SimpleAnimation("look_left", autoplay: false);
    lookRight = SimpleAnimation("look_right", autoplay: false);
    successAnim = SimpleAnimation("success", autoplay: false);
    failAnim = SimpleAnimation("fail", autoplay: false);

    art.addController(intro);

    // ---------------- FIX (correct for Rive 0.12.x) ----------------
    intro.instance?.animation.onStop = () {
      _play(idleLook);
    };
    // ---------------------------------------------------------------

    setState(() => _artboard = art);

    intro.isActive = true;
    _startIdleTimer();
  }

  // ---------------- ANIMATION HELPER ----------------
  void _play(SimpleAnimation anim) {
    anim.isActive = false; // reset
    _artboard?.addController(anim);
    anim.isActive = true;
  }

  // ---------------- IDLE TIMER ----------------
  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 5), () {
      if (!_isInPassword) {
        _play(idleLook);
      }
    });
  }

  // ---------------- LOGIN LOGIC ----------------
  void _attemptLogin() {
    _idleTimer?.cancel();

    final username = _email.text.trim();
    final password = _password.text.trim();

    if (username == _testUser && password == _testPass) {
      _play(successAnim);

      Future.delayed(const Duration(milliseconds: 900), () {
        Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      _play(failAnim);

      Future.delayed(const Duration(seconds: 2), () => _play(idleLook));
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
                            child: Text("username: $_testUser   password: $_testPass"),
                          ),
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: "$_testUser:$_testPass"),
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
                      _isInPassword = false;
                      _play(idleLook);
                      _startIdleTimer();
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (value.length % 2 == 0) {
                          _play(lookLeft);
                        } else {
                          _play(lookRight);
                        }
                      }
                      _startIdleTimer();
                    },
                    decoration: _box("Username"),
                  ),

                  const SizedBox(height: 14),

                  // PASSWORD
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onTap: () {
                      _isInPassword = true;
                      _play(eyeCover); // Keep eyes closed
                      _startIdleTimer();
                    },
                    onChanged: (_) {
                      _isInPassword = true;
                      _play(eyeCover);
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),

          // RIVE ANIMATION
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 260,
              child: _artboard == null
                  ? const Center(child: CircularProgressIndicator())
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
