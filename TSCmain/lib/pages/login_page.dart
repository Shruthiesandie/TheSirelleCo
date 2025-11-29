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
  late SimpleAnimation idleLookAround;
  late SimpleAnimation idle;
  late SimpleAnimation eyeCover;
  late SimpleAnimation successAnim;
  late SimpleAnimation failAnim;

  Timer? idleTimer;

  bool inPassword = false;
  bool introPlaying = false;

  double characterOpacity = 0;

  final _email = TextEditingController();
  final _password = TextEditingController();

  late String _testUser;
  late String _testPass;

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

  // ----------------------------------------------------
  // LOAD RIVE + FADE-IN + PLAY INTRO ONE TIME
  void _loadRive() async {
    final data = await rootBundle.load("assets/animation/login_character.riv");
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    idleLookAround = SimpleAnimation("idle_look_around", autoplay: false);
    idle = SimpleAnimation("idle", autoplay: false);
    eyeCover = SimpleAnimation("eye_cover", autoplay: false);
    successAnim = SimpleAnimation("success", autoplay: false);
    failAnim = SimpleAnimation("fail", autoplay: false);

    _artboard = artboard;

    // Fade in character smoothly
    Future.delayed(Duration(milliseconds: 80), () {
      setState(() => characterOpacity = 1);
    });

    // Play one-time intro fully
    _playIntroOnce();

    // Start idle inactivity timer
    _restartIdleTimer();
  }

  // ----------------------------------------------------
  // ON APP START: Play intro fully ONCE
  void _playIntroOnce() {
    if (_artboard == null) return;

    introPlaying = true;

    idleLookAround = SimpleAnimation("idle_look_around", autoplay: false);
    _artboard!.addController(idleLookAround);
    idleLookAround.isActive = true;

    final dur = idleLookAround.instance?.animation.durationSeconds ?? 2.0;

    Future.delayed(Duration(milliseconds: (dur * 1000).toInt()), () {
      if (!mounted) return;
      introPlaying = false;
      _play("idle");
    });
  }

  // ----------------------------------------------------
  // LOOP idle_look_around continuously until user interacts
  void _loopIdleLook() {
    if (_artboard == null) return;

    introPlaying = true;

    idleLookAround = SimpleAnimation("idle_look_around", autoplay: false);
    _artboard!.addController(idleLookAround);
    idleLookAround.isActive = true;

    final dur = idleLookAround.instance?.animation.durationSeconds ?? 2.0;

    Future.delayed(Duration(milliseconds: (dur * 1000).toInt()), () {
      if (!mounted) return;

      // If user still hasn't interacted → loop again
      if (introPlaying) {
        _loopIdleLook();
      } else {
        _play("idle");
      }
    });
  }

  // ----------------------------------------------------
  // PLAY AN ANIMATION (blocked if intro looping)
  void _play(String name) {
    if (_artboard == null) return;
    if (introPlaying) return;

    final anim = SimpleAnimation(name, autoplay: false);
    _artboard!.addController(anim);
    anim.isActive = true;

    if (name == "idle") idle = anim;
    if (name == "eye_cover") eyeCover = anim;
    if (name == "success") successAnim = anim;
    if (name == "fail") failAnim = anim;
  }

  // ----------------------------------------------------
  // START IDLE AFTER 5 SECONDS OF INACTIVITY
  void _restartIdleTimer() {
    idleTimer?.cancel();
    idleTimer = Timer(const Duration(seconds: 5), () {
      if (!inPassword) {
        _loopIdleLook();  // ⭐ Loop idle_look_around continuously
      }
    });
  }

  // ----------------------------------------------------
  void _attemptLogin() {
    inPassword = false;
    introPlaying = false; // Stop looping idle-look
    idleTimer?.cancel();

    if (_email.text.trim() == _testUser &&
        _password.text.trim() == _testPass) {
      _play("success");

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      _play("fail");

      Future.delayed(const Duration(seconds: 2), () {
        _play("idle");
      });
    }
  }

  // ----------------------------------------------------
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
                            child:
                                Text("username: $_testUser   password: $_testPass"),
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

                  // USERNAME FIELD
                  TextField(
                    controller: _email,
                    onTap: () {
                      introPlaying = false; // ⭐ Stop looping
                      inPassword = false;
                      _play("idle");
                      _restartIdleTimer();
                    },
                    onChanged: (_) {
                      introPlaying = false; // ⭐ Stop looping
                      _restartIdleTimer();
                    },
                    decoration: _box("Username"),
                  ),

                  const SizedBox(height: 14),

                  // PASSWORD FIELD
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onTap: () {
                      introPlaying = false; // ⭐ Stop looping
                      inPassword = true;
                      _play("eye_cover");
                      _restartIdleTimer();
                    },
                    onChanged: (_) {
                      introPlaying = false; // ⭐ Stop looping
                      inPassword = true;
                      _restartIdleTimer();
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),

          // CHARACTER WITH SMOOTH FADE-IN
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: characterOpacity,
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
