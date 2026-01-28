// ------------------------------------------------------------
// PART 1 — Imports, Variables, Rive Loading, Parallax, Eye Follow
// ------------------------------------------------------------

// ignore_for_file: unnecessary_underscores

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Fix gradient naming conflicts with Rive
import 'package:flutter/painting.dart' as fg;

import 'package:firebase_auth/firebase_auth.dart';


import 'package:rive/rive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  Timer? _eyeTimer;
  Timer? _navTimer;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  Artboard? _artboard;

  // ---------------- RIVE ANIMATIONS ----------------
  late SimpleAnimation idle;
  late SimpleAnimation eyeCover;
  late SimpleAnimation successAnim;
  late SimpleAnimation failAnim;

  Timer? idleTimer;
  bool inPassword = false;
  bool _showPassword = false;
  double characterOpacity = 0;

  // Parallax movement
  double tiltX = 0;
  double tiltY = 0;
  final double maxTilt = 10;

  // Eye follow using look_left + look_right
  String lastLook = "center";
  double eyeTriggerCooldown = 0;

  // Page fade animation
  late AnimationController pageController;
  late Animation<double> pageFade;

  // Background animation
  late AnimationController bgController;


  final _email = TextEditingController();
  final _password = TextEditingController();

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    // Page fade animation
    pageController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    pageFade = CurvedAnimation(parent: pageController, curve: Curves.easeOutCubic);
    pageController.forward();

    // Background waves controller
    bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _loadRive();
  }

  @override
  void dispose() {
    _eyeTimer?.cancel();
    _navTimer?.cancel();
    idleTimer?.cancel();
    pageController.dispose();
    bgController.dispose();
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // LOAD RIVE FILE
  // ------------------------------------------------------------
  void _loadRive() async {
    final data = await rootBundle.load("assets/animation/login_character.riv");
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    idle = SimpleAnimation("idle", autoplay: false);
    eyeCover = SimpleAnimation("eye_cover", autoplay: false);
    successAnim = SimpleAnimation("success", autoplay: false);
    failAnim = SimpleAnimation("fail", autoplay: false);

    // Add all controllers to artboard
    artboard.addController(idle);
    artboard.addController(eyeCover);
    artboard.addController(successAnim);
    artboard.addController(failAnim);

    // start with idle
    idle.isActive = true;

    _artboard = artboard;

    // Safe fade-in (never runs after dispose)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => characterOpacity = 1);
    });
  }

  // ------------------------------------------------------------
  // PLAY ANY RIVE ANIMATION
  // ------------------------------------------------------------
  void _play(String name) {
    if (_artboard == null) return;

    idle.isActive = false;
    eyeCover.isActive = false;
    successAnim.isActive = false;
    failAnim.isActive = false;

    switch (name) {
      case "success":
        successAnim.isActive = true;
        break;
      case "fail":
        failAnim.isActive = true;
        break;
      case "eye_cover":
        eyeCover.isActive = true;
        break;
      default:
        idle.isActive = true;
    }
  }

  // ------------------------------------------------------------
  // LOGIN LOGIC
  // ------------------------------------------------------------
  Future<void> _attemptLogin() async {
    inPassword = false;

    final email = _email.text.trim();
    final password = _password.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔥 CRITICAL: force refresh user profile (displayName)
      await FirebaseAuth.instance.currentUser?.reload();

      _play("success");

      // wait for EXACTLY 2 seconds for the success animation before navigating
      const successDuration = Duration(seconds: 2);
      _navTimer?.cancel();
      _navTimer = Timer(successDuration, () {
        if (!mounted) return;
        // Let Splash → AuthGate decide Home/Login
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/home",
          (route) => false,
        );
      });
    } on FirebaseAuthException catch (e) {
      _play("fail");
      _navTimer?.cancel();
      _navTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        _play("idle");
      });

      String msg = "Login failed";
      if (e.code == 'user-not-found') {
        msg = "No account found for this email";
      } else if (e.code == 'wrong-password') {
        msg = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        msg = "Invalid email address";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // PARALLAX + EYE FOLLOW
  // ------------------------------------------------------------
  void _onPointerMove(Offset pos, Size size) {
    final dx = (pos.dx - size.width / 2) / (size.width / 2);
    final dy = (pos.dy - size.height / 2) / (size.height / 2);

    setState(() {
      tiltX = dy * maxTilt;
      tiltY = dx * maxTilt;
    });

    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    if (now - eyeTriggerCooldown < 0.25) return;
    eyeTriggerCooldown = now;

    if (dx < -0.15 && lastLook != "left") {
      lastLook = "left";
      _play("look_left");
    } else if (dx > 0.15 && lastLook != "right") {
      lastLook = "right";
      _play("look_right");
    }
  }

  void _resetTilt() {
    animateSpring(() {
      tiltX = 0;
      tiltY = 0;
    });
  }

  void animateSpring(VoidCallback update) {
    const duration = Duration(milliseconds: 350);
    late AnimationController c;
    c = AnimationController(vsync: this, duration: duration)
      ..addListener(() => setState(update))
      ..forward().whenComplete(() => c.dispose());
  }

  // ------------------------------------------------------------
  // PART 2 — UI Layout, Glass Card, Input Fields, Buttons
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: pageFade,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF5F7),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Listener(
            onPointerHover: (e) => _onPointerMove(e.position, size),
            onPointerMove: (e) => _onPointerMove(e.position, size),
            onPointerUp: (_) => _resetTilt(),
            onPointerCancel: (_) => _resetTilt(),
            child: Stack(
              children: [
                // Background waves
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: bgController,
                    builder: (_, __) => CustomPaint(
                      painter: _WavesPainter(bgController.value),
                    ),
                  ),
                ),

                // Floating orbs
                Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      children: [
                        _orb(0.12, 0.18, 90, Colors.pinkAccent.withValues(alpha: 0.15)),
                        _orb(0.78, 0.12, 110, Colors.purpleAccent.withValues(alpha: 0.18)),
                        _orb(0.30, 0.70, 150, Colors.pink.withValues(alpha: 0.12)),
                        _orb(0.65, 0.55, 100, Colors.purple.withValues(alpha: 0.14)),
                      ],
                    ),
                  ),
                ),

                // Main content
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                      child: Column(
                        children: [
                          _header(),
                          const SizedBox(height: 28),
                          _glassCard(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),

                // Character
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: characterOpacity,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..rotateX(tiltX * pi / 180)
                        ..rotateY(tiltY * pi / 180),
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 260,
                        child: _artboard == null
                            ? const Center(child: CircularProgressIndicator())
                            : Rive(artboard: _artboard!, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------
  Widget _header() {
    return Column(
      children: [
        Text(
          "Welcome Love!",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.pink.shade700,
            shadows: [
              Shadow(
                color: Colors.pink.shade200.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Your soft space awaits you, Sign in",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // GLASS CARD
  // ------------------------------------------------------------
  Widget _glassCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          _inputField(
            controller: _email,
            hint: "Email",
            icon: Icons.person,
            onTap: () {
              inPassword = false;
              _play("idle");
            },
            onChanged: (_) {
              inPassword = false;
            },
          ),

          const SizedBox(height: 20),

          _inputField(
            controller: _password,
            hint: "Password",
            icon: Icons.lock,
            obscure: !_showPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.pink.shade400,
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
            onTap: () {
              inPassword = true;
              _play("eye_cover");

              // wait for FULL eye_cover animation to finish
              final dur =
                  eyeCover.instance?.animation.durationSeconds ?? 0.8;

              _eyeTimer?.cancel();
              _eyeTimer = Timer(
                Duration(milliseconds: (dur * 1000).toInt()),
                () {
                  if (!mounted) return;
                  _play("idle");
                },
              );
            },
            onChanged: (_) {
              // do nothing here — let eye_cover finish fully
            },
          ),

          const SizedBox(height: 28),

          _loginButton(),

          const SizedBox(height: 12),

          // ⭐ ADDED — "Continue as Guest" button
          TextButton(
            onPressed: () {
              // Navigate as Guest (no auth)
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/home",
                (route) => false,
                arguments: {"guest": true},
              );
            },
            child: const Text(
              "Continue as Guest",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ⭐ "Create an account" button
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/register");
            },
            child: const Text(
              "Create an account",
              style: TextStyle(
                color: Colors.pinkAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // INPUT FIELD
  // ------------------------------------------------------------
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    Function()? onTap,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: hint == "Email" ? _emailFocus : _passFocus,
        obscureText: obscure,
        textInputAction:
            hint == "Email" ? TextInputAction.next : TextInputAction.done,
        onSubmitted: (_) {
          if (hint == "Email") {
            FocusScope.of(context).requestFocus(_passFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.pink.shade400),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LOGIN BUTTON
  // ------------------------------------------------------------
  double _press = 1.0;

  Widget _loginButton() {
    return Listener(
      onPointerDown: (_) => setState(() => _press = 0.96),
      onPointerUp: (_) => setState(() => _press = 1.0),
      child: GestureDetector(
        onTap: _attemptLogin,
        child: AnimatedScale(
          scale: _press,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: fg.LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pinkAccent,
                  const Color(0xFFB97BFF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: const Center(
              child: Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FLOATING ORBS
  // ------------------------------------------------------------
  Widget _orb(double x, double y, double size, Color color) {
    return Positioned(
      left: x * MediaQuery.of(context).size.width,
      top: y * MediaQuery.of(context).size.height,
      child: AnimatedBuilder(
        animation: bgController,
        builder: (_, __) {
          final t = bgController.value;
          final dx = sin(t * 2 * pi) * 10;
          final dy = cos(t * 2 * pi) * 10;

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// BACKGROUND WAVES PAINTER
// ------------------------------------------------------------
class _WavesPainter extends CustomPainter {
  final double t;
  _WavesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final fg.Gradient base = fg.LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0xFFFFF3F8),
        Color(0xFFFFEAF4),
        Color(0xFFF3E8FF),
      ],
    );

    final paint = Paint()..shader = base.createShader(rect);
    canvas.drawRect(rect, paint);

    Path wave(double yOffset, double amp, double speed, double stretch) {
      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 6) {
        double nx = (x / size.width) * 2 * pi * stretch;
        double y = yOffset + sin(nx + t * speed * 2 * pi) * amp;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();
      return path;
    }

    canvas.drawPath(
      wave(size.height * 0.78, 22, 1.0, 1.0),
      Paint()
        ..shader = fg.LinearGradient(
          colors: [
            const Color(0xFFFFC9E6).withValues(alpha: 0.95),
            const Color(0xFFFFF0FB).withValues(alpha: 0.7),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    canvas.drawPath(
      wave(size.height * 0.86, 30, 0.6, 1.3),
      Paint()
        ..shader = fg.LinearGradient(
          colors: [
            const Color(0xFFDFB7FF).withValues(alpha: 0.9),
            const Color(0xFFFDEBFF).withValues(alpha: 0.65),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    canvas.drawPath(
      wave(size.height * 0.92, 16, 1.3, 0.8),
      Paint()
        ..shader = fg.LinearGradient(
          colors: [
            const Color(0xFFFFF5F9).withValues(alpha: 0.55),
            const Color(0xFFFAF0FF).withValues(alpha: 0.45),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) =>
      oldDelegate.t != t;
}

/*
────────────────────────────────────────────
Hardcoded Login Credentials:

USERNAME: user123
PASSWORD: 4321
────────────────────────────────────────────
*/
