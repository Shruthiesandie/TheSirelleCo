// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:shimmer/shimmer.dart';

// ─────────────────────────────────────────────
// Background Waves (same style as Login)
// ─────────────────────────────────────────────
class _WavesPainter extends CustomPainter {
  final double t;
  _WavesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final base = const LinearGradient(
      colors: [
        Color(0xFFFFF3F8),
        Color(0xFFFFEAF4),
        Color(0xFFF3E8FF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()..shader = base.createShader(rect);
    canvas.drawRect(rect, paint);

    Path wave(double yOffset, double amp, double speed, double stretch) {
      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 6) {
        double nx = (x / size.width) * 2 * math.pi * stretch;
        double y = yOffset + math.sin(nx + t * speed * 2 * math.pi) * amp;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      return path;
    }

    canvas.drawPath(
      wave(size.height * 0.78, 22, 1.0, 1.0),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFFC9E6),
            Color(0xFFFFF0FB),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) => oldDelegate.t != t;
}

// ─────────────────────────────────────────────
// PAGE STARTS HERE
// ─────────────────────────────────────────────

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage>
    with SingleTickerProviderStateMixin {
  
  // ✨ Your existing controllers & variables
  final _scrollController = ScrollController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  final _firstKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();

  File? _avatar;
  final picker = ImagePicker();

  Country _country = Country.parse("IN");

  final List<String> _genderOptions = ["Male", "Female", "Other"];
  String? _selectedGender;

  bool _attemptSubmit = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _agree = false;

  Color _strengthColor = Colors.transparent;
  double tiltX = 0;
  double tiltY = 0;

  late AnimationController bgCtrl;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_updateStrength);

    bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    bgCtrl.dispose();
    super.dispose();
  }

  // UI functions unchanged…
  void _updateStrength() {
    final p = _passwordCtrl.text;
    if (p.isEmpty) _strengthColor = Colors.transparent;
    else if (p.length < 6) _strengthColor = Colors.red;
    else if (p.length < 10) _strengthColor = Colors.orange;
    else _strengthColor = Colors.green;
    setState(() {});
  }

  void _scrollTo(GlobalKey key) async {
    if (key.currentContext == null) return;
    await Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _err(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

  // Same validation & navigation as before
  void _submit() {
    _attemptSubmit = true;
    if (_firstCtrl.text.isEmpty) {
      _scrollTo(_firstKey);
      return _err("Enter first name");
    }
    if (!_emailCtrl.text.contains("@")) {
      _scrollTo(_emailKey);
      return _err("Enter valid email");
    }
    if (_passwordCtrl.text.length < 6) {
      _scrollTo(_passwordKey);
      return _err("Password too short");
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      return _err("Passwords don't match");
    }
    if (_selectedGender == null) return _err("Select gender");
    if (!_agree) return _err("Accept terms");

    Navigator.pushNamed(context, "/username");
  }

  void _onPointerMove(PointerEvent e) {
    final size = MediaQuery.of(context).size;
    final c = Offset(size.width / 2, size.height / 2);
    final dx = (e.position.dx - c.dx) / c.dx;
    final dy = (e.position.dy - c.dy) / c.dy;
    setState(() {
      tiltY = (dx * 5).clamp(-6.0, 6.0);
      tiltX = (-dy * 5).clamp(-6.0, 6.0);
    });
  }

  void _resetTilt() => setState(() { tiltX = 0; tiltY = 0; });

  // ✨ INPUT FIELD SAME AS BEFORE
  Widget _input(String hint, TextEditingController controller, {IconData? icon, bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.pink.shade300) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // UI BUILD — NEW LOGIN-STYLE LAYOUT
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Listener(
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _resetTilt(),

      child: Scaffold(
        backgroundColor: const Color(0xFFFCEEEE),

        body: Stack(
          children: [

            // Animated background waves
            Positioned.fill(
              child: AnimatedBuilder(
                animation: bgCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _WavesPainter(bgCtrl.value),
                ),
              ),
            ),

            // Floating pastel orbs
            Positioned(
              left: size.width * 0.15,
              top: size.height * 0.18,
              child: _orb(80, Colors.pinkAccent.withOpacity(.18)),
            ),
            Positioned(
              right: size.width * 0.10,
              top: size.height * 0.10,
              child: _orb(105, Colors.purpleAccent.withOpacity(.16)),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
                  child: Column(
                    children: [
                      
                      // TITLE LIKE LOGIN
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.pink.shade700,
                          shadows: [
                            Shadow(
                              color: Colors.pink.shade200.withOpacity(.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text("Let's get started", style: TextStyle(color: Colors.black54, fontSize: 16)),
                      
                      const SizedBox(height: 28),

                      // GLASS CARD (form stays same)
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, .001)
                          ..rotateX(tiltX * math.pi / 180)
                          ..rotateY(tiltY * math.pi / 180),

                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.65),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white.withOpacity(.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.08),
                                blurRadius: 25,
                                offset: const Offset(0, 14),
                              )
                            ],
                          ),

                          child: Column(
                            children: [

                              // EVERYTHING FROM YOUR ORIGINAL PAGE
                              _avatarPicker(),
                              const SizedBox(height: 22),

                              Row(children: [
                                Expanded(child: Container(key: _firstKey, child: _input("First Name", _firstCtrl, icon: Icons.person))),
                                const SizedBox(width: 12),
                                Expanded(child: _input("Last Name", _lastCtrl, icon: Icons.person_outline)),
                              ]),

                              const SizedBox(height:16),
                              Container(key: _emailKey, child: _input("Email", _emailCtrl, icon: Icons.email)),

                              const SizedBox(height:16),
                              _phoneCountryBlock(),

                              const SizedBox(height:16),
                              GestureDetector(onTap: _pickDOB, child: AbsorbPointer(child: _input("DOB (YYYY-MM-DD)", _dobCtrl, icon: Icons.cake))),

                              const SizedBox(height:16),
                              Stack(alignment: Alignment.centerRight, children: [
                                Container(key: _passwordKey, child: _input("Password", _passwordCtrl, icon: Icons.lock, obscure: _obscure)),
                                Positioned(
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: ()=>setState(()=>_obscure = !_obscure),
                                    child: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                  ),
                                ),
                              ]),

                              const SizedBox(height:16),
                              Stack(alignment:Alignment.centerRight, children: [
                                _input("Re-enter Password", _confirmCtrl, icon: Icons.lock, obscure: _obscureConfirm),
                                Positioned(
                                  right: 12,
                                  child: GestureDetector(
                                    onTap:()=>setState(()=>_obscureConfirm = !_obscureConfirm),
                                    child: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                                  ),
                                ),
                              ]),

                              if (_confirmCtrl.text.isNotEmpty && _confirmCtrl.text != _passwordCtrl.text)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Passwords don't match", style: TextStyle(color: Colors.red.shade400)),
                                ),

                              const SizedBox(height:20),
                              _genderPicker(),

                              Row(children: [
                                Checkbox(value: _agree, onChanged:(v)=>setState(()=>_agree = v ?? false)),
                                const Expanded(child: Text("I agree to Terms & Privacy Policy")),
                              ]),

                              GestureDetector(
                                onTap: _submit,
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                                    ),
                                  ),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.white,
                                    highlightColor: Colors.white70,
                                    child: const Center(
                                      child: Text("CREATE ACCOUNT", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating orb widget
  Widget _orb(double size, Color color) => Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );

  // Avatar picker preserved
  Widget _avatarPicker() { … same as your original code … }
  Widget _phoneCountryBlock() { … same as original … }
  Widget _genderPicker() { … same as original … }
  Future<void> _pickDOB() async { … same as original … }
}