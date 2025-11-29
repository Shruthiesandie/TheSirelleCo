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

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
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

  // Aesthetic page fade animation
  late AnimationController pageController;
  late Animation<double> pageFade;

  final _email = TextEditingController();
  final _password = TextEditingController();

  // Hardcoded login (as requested)
  final String hardUser = "user123";
  final String hardPass = "4321";

  @override
  void initState() {
    super.initState();

    pageController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    pageFade = CurvedAnimation(parent: pageController, curve: Curves.easeOut);

    pageController.forward();

    _loadRive();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
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

    Future.delayed(Duration(milliseconds: 80), () {
      setState(() => characterOpacity = 1);
    });

    _playIntroOnce();
    _restartIdleTimer();
  }

  // ----------------------------------------------------
  // INTRO PLAY ONCE
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

      if (introPlaying) {
        _loopIdleLook();
      } else {
        _play("idle");
      }
    });
  }

  // ----------------------------------------------------
  // PLAY ANIMATION
  void _play(String name) {
    if (_artboard == null) return;
    if (introPlaying) return;

    final anim = SimpleAnimation(name, autoplay: false);
    _artboard!.addController(anim);
    anim.isActive = true;
  }

  // ----------------------------------------------------
  // 5 SEC IDLE REACTION
  void _restartIdleTimer() {
    idleTimer?.cancel();
    idleTimer = Timer(const Duration(seconds: 5), () {
      if (!inPassword) {
        _loopIdleLook();
      }
    });
  }

  // ----------------------------------------------------
  void _attemptLogin() {
    inPassword = false;
    introPlaying = false;
    idleTimer?.cancel();

    if (_email.text.trim() == hardUser &&
        _password.text.trim() == hardPass) {
      _play("success");

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      _play("fail");
      Future.delayed(const Duration(seconds: 2), () => _play("idle"));
    }
  }

  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: pageFade,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCEEEE),
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      Text(
                        "Welcome Back 👋",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Login to continue",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ✨ GLASS CARD ✨
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.2),
                              blurRadius: 25,
                              offset: Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // USERNAME FIELD
                            _animatedField(
                              controller: _email,
                              hint: "Username",
                              onTap: () {
                                introPlaying = false;
                                inPassword = false;
                                _play("idle");
                                _restartIdleTimer();
                              },
                              onChanged: (_) {
                                introPlaying = false;
                                _restartIdleTimer();
                              },
                            ),
                            const SizedBox(height: 20),

                            // PASSWORD FIELD
                            _animatedField(
                              controller: _password,
                              hint: "Password",
                              obscure: true,
                              onTap: () {
                                introPlaying = false;
                                inPassword = true;
                                _play("eye_cover");
                                _restartIdleTimer();
                              },
                              onChanged: (_) {
                                introPlaying = false;
                                inPassword = true;
                                _restartIdleTimer();
                              },
                            ),

                            const SizedBox(height: 30),

                            // ANIMATED LOGIN BUTTON 🔥
                            MouseRegion(
                              onEnter: (_) => setState(() {}),
                              onExit: (_) => setState(() {}),
                              child: GestureDetector(
                                onTap: _attemptLogin,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 50),
                                  decoration: BoxDecoration(
                                    color: Colors.pinkAccent,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pinkAccent.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: Offset(0, 8),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),

            // CHARACTER
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
      ),
    );
  }

  // ----------------------------------------------------
  // ANIMATED TEXT FIELD WIDGET
  Widget _animatedField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Function()? onTap,
    Function(String)? onChanged,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

/*
──────────────────────────────────────────────────────
Hardcoded Login Credentials (as requested):

USERNAME: user123
PASSWORD: 4321
──────────────────────────────────────────────────────
*/
