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
  bool isIntroPlaying = false;

  double characterOpacity = 0;  // ⭐ For smooth fade-in

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
  // LOAD RIVE + FADE-IN + INTRO
  void _loadRive() async {
    final data = await rootBundle.load("assets/animation/login_character.riv");
    final file = RiveFile.import(data);

    final artboard = file.mainArtboard;

    // Load animations
    idleLookAround = SimpleAnimation("idle_look_around", autoplay: false);
    idle = SimpleAnimation("idle", autoplay: false);
    eyeCover = SimpleAnimation("eye_cover", autoplay: false);
    successAnim = SimpleAnimation("success", autoplay: false);
    failAnim = SimpleAnimation("fail", autoplay: false);

    // Start intro animation
    isIntroPlaying = true;
    artboard.addController(idleLookAround);
    idleLookAround.isActive = true;

    setState(() => _artboard = artboard);

    // ⭐ Smooth fade-in
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => characterOpacity = 1);
    });

    // After intro → idle
    Future.delayed(const Duration(seconds: 2), () {
      isIntroPlaying = false;
      _play("idle");
    });

    _restartIdleTimer();
  }

  // ----------------------------------------------------
  // PLAY ANY ANIMATION BY NAME
  void _play(String name) {
    if (_artboard == null) return;

    if (isIntroPlaying) return;

    final anim = SimpleAnimation(name, autoplay: false);
    _artboard!.addController(anim);
    anim.isActive = true;

    if (name == "idle_look_around") idleLookAround = anim;
    if (name == "idle") idle = anim;
    if (name == "eye_cover") eyeCover = anim;
    if (name == "success") successAnim = anim;
    if (name == "fail") failAnim = anim;
  }

  // ----------------------------------------------------
  // FIX: IDLE-LOOK-AROUND SHOULD PLAY AFTER 5 SEC
  void _restartIdleTimer() {
    idleTimer?.cancel();
    idleTimer = Timer(const Duration(seconds: 5), () {
      if (!inPassword) {
        isIntroPlaying = true;

        // ⭐ Directly add controller (DON’T use _play, it blocks intro!)
        final intro = SimpleAnimation("idle_look_around", autoplay: false);
        _artboard!.addController(intro);
        intro.isActive = true;
        idleLookAround = intro;

        // After intro finishes → go idle
        Future.delayed(const Duration(seconds: 2), () {
          isIntroPlaying = false;
          _play("idle");
        });
      }
    });
  }

  // ----------------------------------------------------
  // LOGIN
  void _attemptLogin() {
    inPassword = false;
    idleTimer?.cancel();

    if (_email.text.trim() == _testUser &&
        _password.text.trim() == _testPass) {
      _play("success");

      Future.delayed(const Duration(milliseconds: 900), () {
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
                            child: Text(
                                "username: $_testUser   password: $_testPass"),
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
                      inPassword = false;
                      _play("idle");
                      _restartIdleTimer();
                    },
                    onChanged: (_) {
                      _restartIdleTimer();
                    },
                    decoration: _box("Username"),
                  ),

                  const SizedBox(height: 14),

                  // PASSWORD — ONLY TAP PLAYS EYE COVER
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onTap: () {
                      inPassword = true;
                      _play("eye_cover");
                      _restartIdleTimer();
                    },
                    onChanged: (_) {
                      inPassword = true;
                      _restartIdleTimer(); // NO animation here
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

          // ⭐ SMOOTH FADE-IN CHARACTER
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: characterOpacity,
              child: SizedBox(
                height: 260,
                child: _artboard == null
                    ? const Center(child: CircularProgressIndicator())
                    : Rive(artboard: _artboard!, fit: BoxFit.contain),
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
