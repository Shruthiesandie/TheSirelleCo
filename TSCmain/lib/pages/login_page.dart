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

  // Rive animations
  late SimpleAnimation idleLookAround;
  late SimpleAnimation idle;
  late SimpleAnimation eyeCover;
  late SimpleAnimation successAnim;
  late SimpleAnimation failAnim;

  Timer? idleTimer;

  bool inPassword = false;
  bool introPlaying = false;
  double characterOpacity = 0;

  // Page appearance animation
  late AnimationController pageController;
  late Animation<double> pageFade;

  // Background animation (blobs + waves)
  late AnimationController bgController;

  final _email = TextEditingController();
  final _password = TextEditingController();

  // Hardcoded credentials (used for login check)
  final String hardUser = "user123";
  final String hardPass = "4321";

  @override
  void initState() {
    super.initState();

    pageController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    pageFade = CurvedAnimation(parent: pageController, curve: Curves.easeOutCubic);
    pageController.forward();

    bgController = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    _loadRive();
  }

  @override
  void dispose() {
    pageController.dispose();
    bgController.dispose();
    idleTimer?.cancel();
    _email.dispose();
    _password.dispose();
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

    // Smooth fade-in for character container
    Future.delayed(const Duration(milliseconds: 80), () {
      setState(() => characterOpacity = 1);
    });

    // Play intro once & start idle timer
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
  // PLAY ANIMATION (non-intro)
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
      Future.delayed(const Duration(seconds: 2), () {
        _play("idle");
      });
    }
  }

  // ----------------------------------------------------
  // Helper: subtle scale effect for button press
  double _pressScale = 1.0;
  void _onButtonDown() => setState(() => _pressScale = 0.98);
  void _onButtonUp() => setState(() => _pressScale = 1.0);

  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return FadeTransition(
      opacity: pageFade,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF5F7),
        body: Stack(
          children: [
            // Animated gradient waves painter + soft blobs
            Positioned.fill(
              child: AnimatedBuilder(
                animation: bgController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _WavesPainter(bgController.value),
                    child: Stack(
                      children: [
                        // Floating soft blobs (parallax)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Stack(
                              children: [
                                _floatingBlob(
                                  leftFactor: 0.05,
                                  topFactor: 0.08,
                                  size: w * 0.42,
                                  color: const Color(0xFFFFE6F0),
                                  offsetPhase: bgController.value,
                                  blur: 60,
                                ),
                                _floatingBlob(
                                  leftFactor: 0.65,
                                  topFactor: 0.12,
                                  size: w * 0.36,
                                  color: const Color(0xFFEDD6FF),
                                  offsetPhase: (bgController.value + 0.35) % 1,
                                  blur: 40,
                                ),
                                _floatingBlob(
                                  leftFactor: 0.28,
                                  topFactor: 0.62,
                                  size: w * 0.5,
                                  color: const Color(0xFFFFD7E8),
                                  offsetPhase: (bgController.value + 0.6) % 1,
                                  blur: 80,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      _buildHeader(),
                      const SizedBox(height: 28),

                      // Glass card with inputs + button
                      _buildGlassCard(context),

                      const SizedBox(height: 30),
                      // subtle tip line
                      Text(
                        "Secure login • Animated character powered by Rive",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.45),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Character slot with subtle glow & elevation
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pinkAccent.withOpacity(0.12),
                      Color(0xFFB97BFF).withOpacity(0.08)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.08),
                      blurRadius: 30,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: characterOpacity,
                  child: SizedBox(
                    height: 260,
                    width: 360,
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
    );
  }

  // Header with title + accent underline
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.pink.shade700,
            shadows: [
              Shadow(
                color: Colors.pink.shade100.withOpacity(0.8),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 4, decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.circular(3),
            )),
            const SizedBox(width: 8),
            Text(
              "Sign in to continue",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  // Build fancy glass card
  Widget _buildGlassCard(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Soft glow behind card
          Positioned(
            top: -30,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.pinkAccent.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Glass container
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // small subtitle
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.pink.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // username field
                _fancyTextField(
                  controller: _email,
                  hint: "Username",
                  prefix: Icons.person,
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

                const SizedBox(height: 16),

                // password field
                _fancyTextField(
                  controller: _password,
                  hint: "Password",
                  prefix: Icons.lock,
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

                const SizedBox(height: 20),

                // Animated button + helper row
                Row(
                  children: [
                    Expanded(
                      child: Listener(
                        onPointerDown: (_) => _onButtonDown(),
                        onPointerUp: (_) => _onButtonUp(),
                        child: GestureDetector(
                          onTap: _attemptLogin,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 120),
                            scale: _pressScale,
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFFF6FAF),
                                    const Color(0xFFB97BFF),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6FAF).withOpacity(0.28),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.login, color: Colors.white),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // small ghost button: forgot
                    Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Center(
                          child: Text(
                        "Help",
                        style: TextStyle(color: Colors.pink.shade700),
                      )),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fancy text field with floating label visual
  Widget _fancyTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    IconData? prefix,
    Function()? onTap,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onTap: onTap,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: prefix != null
              ? Icon(prefix, color: Colors.pink.shade400)
              : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Floating blob builder (soft blurred shape)
  Widget _floatingBlob({
    required double leftFactor,
    required double topFactor,
    required double size,
    required Color color,
    required double offsetPhase,
    required double blur,
  }) {
    // offsetPhase: 0..1, we use sin wave for motion
    final dx = sin(offsetPhase * 2 * pi) * 18;
    final dy = cos(offsetPhase * 2 * pi) * 10;

    return Positioned(
      left: leftFactor * MediaQuery.of(context).size.width + dx,
      top: topFactor * MediaQuery.of(context).size.height + dy,
      child: Transform.translate(
        offset: Offset(dx * 0.2, dy * 0.2),
        child: Container(
          width: size,
          height: size * 0.64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.95),
                color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.36),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: blur,
                spreadRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Waves painter: draws layered gradient waves that animate with t (0..1)
class _WavesPainter extends CustomPainter {
  final double t;
  _WavesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // background gradient
    final Rect rect = Offset.zero & size;
    final Gradient bgGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFF3F8),
        Color(0xFFFFEAF4),
        Color(0xFFF3E8FF),
      ],
      stops: [0.0, 0.5, 1.0],
    );
    final Paint bgPaint = Paint()..shader = bgGrad.createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // helper to draw a sin wave path
    Path wavePath(double yOffset, double amplitude, double phase, double stretch) {
      final Path p = Path();
      p.moveTo(0, size.height);
      // sample across width
      for (double x = 0; x <= size.width; x += 8) {
        final double fx = (x / size.width) * 2 * pi * stretch;
        final double y = yOffset + sin(fx + phase) * amplitude;
        p.lineTo(x, y);
      }
      p.lineTo(size.width, size.height);
      p.close();
      return p;
    }

    // parameters driven by t
    final double p1 = t * 2 * pi;
    // Wave 1 (closest): pinkish
    final Paint paint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFFFFC9E6).withOpacity(0.98),
          Color(0xFFFFF0FB).withOpacity(0.7)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12);
    final Path w1 = wavePath(size.height * 0.78, 22, p1 * 1.0, 1.0);
    canvas.drawPath(w1, paint1);

    // Wave 2: violet
    final Paint paint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFFDFB7FF).withOpacity(0.9),
          Color(0xFFFDEBFF).withOpacity(0.65)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18);
    final Path w2 = wavePath(size.height * 0.86, 30, p1 * 0.6, 1.2);
    canvas.drawPath(w2, paint2);

    // Wave 3: subtle bottom glow
    final Paint paint3 = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFFFFF5F9).withOpacity(0.6),
          Color(0xFFFAF0FF).withOpacity(0.5),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    final Path w3 = wavePath(size.height * 0.92, 16, p1 * 1.4, 0.8);
    canvas.drawPath(w3, paint3);
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) => oldDelegate.t != t;
}

/*
──────────────────────────────────────────────────────
Hardcoded Login Credentials (as requested):

USERNAME: user123
PASSWORD: 4321
──────────────────────────────────────────────────────
*/
