// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures, deprecated_member_use

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:shimmer/shimmer.dart';

/// ─────────────────────────────────────────────────────────
/// Soft animated waves background (matching login style)
/// ─────────────────────────────────────────────────────────
class _CreateWavesPainter extends CustomPainter {
  final double t;
  _CreateWavesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final base = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFF3F8),
        Color(0xFFFFEAF4),
        Color(0xFFF3E8FF),
      ],
    );

    final paint = Paint()..shader = base.createShader(rect);
    canvas.drawRect(rect, paint);

    Path wave(double yOffset, double amp, double speed, double stretch) {
      final path = Path()..moveTo(0, size.height);
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

    canvas.drawPath(
      wave(size.height * 0.88, 26, 0.8, 1.2),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFDFB7FF),
            Color(0xFFFDEBFF),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  @override
  bool shouldRepaint(covariant _CreateWavesPainter oldDelegate) =>
      oldDelegate.t != t;
}

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage>
    with TickerProviderStateMixin {
  // Controllers
  final _scrollController = ScrollController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  // Keys
  final _firstKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();

  // Avatar
  File? _avatar;
  final ImagePicker _picker = ImagePicker();

  // Country
  Country _country = Country.parse("IN");

  // Gender
  final List<String> _genderOptions = ["Male", "Female", "Other"];
  String? _selectedGender;

  // UI flags
  bool _attemptSubmit = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _agree = false;

  // Password strength
  Color _strengthColor = Colors.transparent;

  // Tilt effect
  double _tiltX = 0;
  double _tiltY = 0;

  // Glow animation (gender)
  late AnimationController _glowCtrl;
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;

  // Background animation (waves / orbs)
  late AnimationController _bgCtrl;

  bool _phoneFormatting = false;

  final BorderSide _blackBorder =
      const BorderSide(color: Colors.black87, width: 1.0);

  @override
  void initState() {
    super.initState();

    _passwordCtrl.addListener(_updateStrength);
    _confirmCtrl.addListener(() => setState(() {}));
    _phoneCtrl.addListener(_phoneFormatListener);

    // Gender pulse glow
    _glowCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowScale = Tween<double>(begin: 1.0, end: 1.35)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut));
    _glowOpacity = Tween<double>(begin: 0.20, end: 0.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut));

    // Background waves
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _phoneCtrl.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    _glowCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  // Avatar Picker
  Future<void> _pickAvatar(ImageSource src) async {
    final picked = await _picker.pickImage(source: src, imageQuality: 85);
    if (picked != null) setState(() => _avatar = File(picked.path));
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take photo'),
            onTap: () {
              Navigator.pop(c);
              _pickAvatar(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(c);
              _pickAvatar(ImageSource.gallery);
            },
          ),
          if (_avatar != null)
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove photo'),
              onTap: () {
                Navigator.pop(c);
                setState(() => _avatar = null);
              },
            ),
        ]),
      ),
    );
  }

  // Country Picker
  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (c) => setState(() => _country = c),
    );
  }

  // DOB Picker
  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 10),
    );
    if (picked != null) {
      _dobCtrl.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // Phone formatting
  void _phoneFormatListener() {
    if (_phoneFormatting) return;
    _phoneFormatting = true;

    final raw = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    String f;

    if (raw.length <= 3) {
      f = raw;
    } else if (raw.length <= 6) {
      f = "${raw.substring(0, 3)} ${raw.substring(3)}";
    } else if (raw.length <= 10) {
      f =
          "${raw.substring(0, 3)} ${raw.substring(3, 6)} ${raw.substring(6)}";
    } else {
      f = raw;
    }

    _phoneCtrl.value = TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );

    _phoneFormatting = false;
  }

  // Password Strength
  void _updateStrength() {
    final p = _passwordCtrl.text;

    if (p.isEmpty) {
      _strengthColor = Colors.transparent;
    } else if (p.length < 6) {
      _strengthColor = Colors.red;
    } else if (p.length < 10) {
      _strengthColor = Colors.orange;
    } else {
      _strengthColor = Colors.green;
    }

    setState(() {});
  }

  void _err(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _scrollTo(GlobalKey key) async {
    if (key.currentContext == null) return;
    await Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _submit() {
    _attemptSubmit = true;

    if (_firstCtrl.text.isEmpty) {
      _scrollTo(_firstKey);
      return _err("Enter first name");
    }
    if (!_emailCtrl.text.contains("@")) {
      _scrollTo(_emailKey);
      return _err("Enter a valid email");
    }
    if (_passwordCtrl.text.length < 6) {
      _scrollTo(_passwordKey);
      return _err("Password too short");
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      return _err("Passwords do not match");
    }
    if (_selectedGender == null) {
      return _err("Please select gender");
    }
    if (!_agree) {
      return _err("Please accept the terms");
    }

    _createAccount();
  }

  Future<void> _createAccount() async {
    // Local dummy account creation (no Firebase)
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Account created locally. Please login."),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacementNamed(context, "/login");
  }

  // Tilt Effect
  void _onPointerMove(PointerEvent e) {
    final size = MediaQuery.of(context).size;
    final c = Offset(size.width / 2, size.height / 2);
    final dx = (e.position.dx - c.dx) / c.dx;
    final dy = (e.position.dy - c.dy) / c.dy;

    setState(() {
      _tiltY = (dx * 6).clamp(-8.0, 8.0);
      _tiltX = (-dy * 6).clamp(-8.0, 8.0);
    });
  }

  void _resetTilt() => setState(() {
        _tiltX = 0;
        _tiltY = 0;
      });

  Widget _input(
    String hint,
    TextEditingController controller, {
    IconData? icon,
    TextInputType? type,
    bool obscure = false,
  }) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.pink.shade300) : null,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: _blackBorder,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: _blackBorder,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // Small strength dot
  Widget _strengthDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _strengthColor,
        shape: BoxShape.circle,
      ),
    );
  }

  // Gender selector (kept as is, just aesthetic)
  Widget _genderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _genderOptions.map((g) {
            final selected = (_selectedGender == g);

            return GestureDetector(
              onTap: () => setState(() {
                _selectedGender = g;
                _attemptSubmit = false;
              }),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (selected)
                    AnimatedBuilder(
                      animation: _glowCtrl,
                      builder: (_, __) {
                        return Transform.scale(
                          scale: _glowScale.value,
                          child: Opacity(
                            opacity: _glowOpacity.value,
                            child: Container(
                              width: 110,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? Colors.pink.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color:
                            selected ? Colors.pink.shade400 : Colors.black87,
                        width: 1.0,
                      ),
                    ),
                    child: AnimatedScale(
                      scale: selected ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 260),
                      child: Text(
                        g,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.pink.shade600
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (_selectedGender == null && _attemptSubmit)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Please select gender",
              style: TextStyle(color: Colors.red.shade400),
            ),
          ),
      ],
    );
  }

  // Floating orb like login
  Widget _orb(double x, double y, double size, Color color) {
    final screen = MediaQuery.of(context).size;
    return Positioned(
      left: x * screen.width,
      top: y * screen.height,
      child: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) {
          final t = _bgCtrl.value;
          final dx = math.sin(t * 2 * math.pi) * 10;
          final dy = math.cos(t * 2 * math.pi) * 10;
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

  // FULL UI
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _resetTilt(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF5F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: Colors.black87),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Background waves
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _CreateWavesPainter(_bgCtrl.value),
                ),
              ),
            ),

            // Floating orbs
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  children: [
                    _orb(0.08, 0.14, 90,
                        Colors.pinkAccent.withOpacity(0.16)),
                    _orb(0.78, 0.10, 110,
                        Colors.purpleAccent.withOpacity(0.18)),
                    _orb(0.30, 0.72, 150,
                        Colors.pink.withOpacity(0.12)),
                  ],
                ),
              ),
            ),

            // Main content
            SingleChildScrollView(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_tiltX * math.pi / 180)
                  ..rotateY(_tiltY * math.pi / 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header like login
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.pink.shade700,
                        shadows: [
                          Shadow(
                            color:
                                Colors.pink.shade200.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Let’s get you started",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Glass card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 26,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _showAvatarOptions,
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.pink.shade50,
                                        Colors.purple.shade50,
                                      ],
                                    ),
                                    border: Border.all(
                                        color: Colors.white, width: 4),
                                  ),
                                  child: ClipOval(
                                    child: _avatar == null
                                        ? Icon(
                                            Icons.camera_alt_outlined,
                                            size: 34,
                                            color: Colors.pink.shade300,
                                          )
                                        : Image.file(
                                            _avatar!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "Upload profile photo",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // First + Last name
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  key: _firstKey,
                                  child: _input("First name", _firstCtrl,
                                      icon: Icons.person),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _input(
                                    "Last name", _lastCtrl,
                                    icon: Icons.person_outline),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Email
                          Container(
                            key: _emailKey,
                            child: _input(
                              "Email",
                              _emailCtrl,
                              icon: Icons.email,
                              type: TextInputType.emailAddress,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Country + Phone
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _openCountryPicker,
                                child: Container(
                                  height: 52,
                                  width: 110,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: Colors.black87, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "+${_country.phoneCode}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _country.flagEmoji,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.black87,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _input(
                                  "Phone number",
                                  _phoneCtrl,
                                  icon: Icons.phone,
                                  type: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // DOB
                          GestureDetector(
                            onTap: _pickDOB,
                            child: AbsorbPointer(
                              child: _input(
                                "DOB (YYYY-MM-DD)",
                                _dobCtrl,
                                icon: Icons.cake,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password
                          Container(
                            key: _passwordKey,
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                _input(
                                  "Password",
                                  _passwordCtrl,
                                  icon: Icons.lock,
                                  obscure: _obscure,
                                ),
                                Positioned(
                                  right: 12,
                                  child: Row(
                                    children: [
                                      _strengthDot(),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () => setState(
                                            () => _obscure = !_obscure),
                                        child: Icon(
                                          _obscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Confirm password
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              _input(
                                "Re-enter password",
                                _confirmCtrl,
                                icon: Icons.lock,
                                obscure: _obscureConfirm,
                              ),
                              Positioned(
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => setState(() =>
                                      _obscureConfirm = !_obscureConfirm),
                                  child: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (_confirmCtrl.text.isNotEmpty &&
                              _confirmCtrl.text != _passwordCtrl.text)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Passwords do not match",
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 22),

                          _genderSelector(),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Checkbox(
                                value: _agree,
                                onChanged: (v) =>
                                    setState(() => _agree = v ?? false),
                              ),
                              const Expanded(
                                child: Text(
                                  "I agree to the Terms & Privacy Policy",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Submit button
                          GestureDetector(
                            onTap: _submit,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6FAF),
                                    Color(0xFFB97BFF),
                                  ],
                                ),
                              ),
                              child: Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.white70,
                                child: const Center(
                                  child: Text(
                                    "CREATE ACCOUNT",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Contact support",
                          style: TextStyle(color: Colors.pink.shade400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}