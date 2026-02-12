// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_underscores

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  // Allowed characters regex
  final RegExp _validRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  // Preblocked usernames

  // status = empty, checking, taken, available
  String status = "empty";

  bool loading = false;

  // Success animation
  late AnimationController successCtrl;
  late Animation<double> successScale;

  late AnimationController bgController;

  // Button hover + press animations
  double btnScale = 1.0;
  double cardLift = 0;

  @override
  void initState() {
    super.initState();

    successCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

    successScale = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(parent: successCtrl, curve: Curves.easeOutBack),
    );

    bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    successCtrl.dispose();
    bgController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // CHECK USERNAME
  // ---------------------------------------------------------------------------
  Future<void> checkUsername(String value) async {
    value = value.trim().toLowerCase();

    if (value.isEmpty) {
      setState(() => status = "empty");
      return;
    }

    if (value.contains(" ")) {
      setState(() => status = "space");
      return;
    }

    if (!_validRegex.hasMatch(value)) {
      setState(() => status = "invalid");
      return;
    }

    if (value.length < 3) {
      setState(() => status = "short");
      return;
    }

    setState(() {
      loading = false;
      status = "available";
    });

    successCtrl.forward().then((_) => successCtrl.reverse());
  }

  // ---------------------------------------------------------------------------
  // COLORS & TEXT HELPERS
  // ---------------------------------------------------------------------------
  Color getBorderColor() {
    switch (status) {
      case "checking":
        return Colors.blueAccent;
      case "available":
        return Colors.greenAccent.shade400;
      case "taken":
        return Colors.redAccent;
      case "short":
      case "invalid":
      case "space":
        return Colors.orange;
      default:
        return Colors.transparent;
    }
  }

  String getStatusText() {
    switch (status) {
      case "checking":
        return "Checking availability…";
      case "available":
        return "Username available ✓";
      case "taken":
        return "Already exists ✗";
      case "invalid":
        return "Only letters, numbers, underscore allowed";
      case "space":
        return "No spaces allowed";
      case "short":
        return "Must be at least 3 characters";
      default:
        return "";
    }
  }

  Color getDotColor() {
    switch (status) {
      case "checking":
        return Colors.blueAccent;
      case "available":
        return Colors.green;
      case "taken":
      case "invalid":
      case "space":
      case "short":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ---------------------------------------------------------------------------
  // RULE CHIPS
  // ---------------------------------------------------------------------------
  Widget _ruleChip(String text, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: active
            ? const LinearGradient(
                colors: [Color(0xFFB0FFCA), Color(0xFFE4FFE9)],
              )
            : LinearGradient(
                colors: [Colors.white, Colors.white.withOpacity(0.85)],
              ),
        border: Border.all(
          color: active ? Colors.green.shade600 : Colors.black12,
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.24),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? Colors.green.shade700 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              color: active ? Colors.green.shade800 : Colors.black45,
              fontSize: 12.5,
              letterSpacing: active ? 0.4 : 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return MouseRegion(
      onEnter: (_) => setState(() => cardLift = -4),
      onExit: (_) => setState(() => cardLift = 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(0, cardLift, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: getBorderColor(),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.12),
              blurRadius: 22,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (_) {},
              decoration: InputDecoration(
                hintText: "Enter username",
                prefixIcon: Icon(Icons.person, color: Colors.pink.shade300),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: getDotColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  getStatusText(),
                  style: TextStyle(
                    color: status == "available"
                        ? Colors.green.shade800
                        : Colors.red.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.start,
              runSpacing: 10,
              children: [
                _ruleChip(
                  "Min 3 chars",
                  _controller.text.isNotEmpty &&
                      _controller.text.trim().length >= 3,
                ),
                _ruleChip(
                  "No symbols — keep it simple",
                  _controller.text.isNotEmpty &&
                      _validRegex.hasMatch(_controller.text.trim()),
                ),
                _ruleChip(
                  "No spaces",
                  _controller.text.isNotEmpty &&
                      !_controller.text.contains(" "),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Listener(
      onPointerDown: (_) => setState(() => btnScale = 0.95),
      onPointerUp: (_) => setState(() => btnScale = 1.0),
      child: GestureDetector(
        onTap: () async {
          final username = _controller.text.trim().toLowerCase();
          final user = FirebaseAuth.instance.currentUser;

          if (user == null) return;

          await user.updateDisplayName(username);

          // 🔁 SAVE USERNAME TO MYSQL VIA NODE BACKEND
          final res = await http.post(
            Uri.parse("http://192.168.0.150:3000/username"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "firebaseUid": user.uid,
              "username": username,
            }),
          );

          if (res.statusCode != 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to save username")),
            );
            return;
          }

          // 🔑 Sign out before going to Login page
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;
          Navigator.pushReplacementNamed(context, "/login");
        },
        child: AnimatedScale(
          scale: btnScale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF6FAF),
                    Color(0xFFB97BFF),
                  ],
                ),
              ),
              child: Center(
                child: ScaleTransition(
                  scale: successScale,
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Listener(
              onPointerHover: (_) {},
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: bgController,
                      builder: (_, __) => CustomPaint(
                        painter: _WavesPainter(bgController.value),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Stack(
                        children: [
                          _orb(0.15, 0.25, 90, Colors.pinkAccent.withOpacity(0.12)),
                          _orb(0.75, 0.18, 120, Colors.purpleAccent.withOpacity(0.15)),
                          _orb(0.35, 0.70, 140, Colors.pink.withOpacity(0.10)),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Choose a username",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.pink.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "This will be your identity in the app.",
                            style: TextStyle(color: Colors.black54, fontSize: 15),
                          ),
                          const SizedBox(height: 35),
                          _buildCard(),
                          const SizedBox(height: 60),
                          _buildContinueButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _orb(double x, double y, double size, Color color) {
  return Positioned(
    left: x * WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio,
    top: y * WidgetsBinding.instance.window.physicalSize.height / WidgetsBinding.instance.window.devicePixelRatio,
    child: _OrbAnimation(size: size, color: color),
  );
}

class _OrbAnimation extends StatefulWidget {
  final double size;
  final Color color;
  const _OrbAnimation({required this.size, required this.color});

  @override
  State<_OrbAnimation> createState() => _OrbAnimationState();
}

class _OrbAnimationState extends State<_OrbAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        final dx = sin(t * 2 * pi) * 10;
        final dy = cos(t * 2 * pi) * 10;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _WavesPainter extends CustomPainter {
  final double t;
  _WavesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final Gradient base = LinearGradient(
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

    Path wave(double baseY, double amp, double speed, double stretch) {
      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 6) {
        double nx = (x / size.width) * 2 * pi * stretch;
        double y = baseY + sin(nx + t * speed * 2 * pi) * amp;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();
      return path;
    }

    canvas.drawPath(
      wave(size.height * 0.81, 18, 1.0, 1.2),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFC9E6).withOpacity(0.9),
            const Color(0xFFFFF0FB).withOpacity(0.7),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    canvas.drawPath(
      wave(size.height * 0.88, 28, 0.7, 1.4),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFDFB7FF).withOpacity(0.85),
            const Color(0xFFFDEBFF).withOpacity(0.6),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawPath(
      wave(size.height * 0.94, 16, 1.4, 0.9),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF5F9).withOpacity(0.5),
            const Color(0xFFFAF0FF).withOpacity(0.4),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) => oldDelegate.t != t;
}
