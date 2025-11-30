// create_account_page.dart
// FINAL VERSION — Animated Pulse Glow Gender Pills (Crash-Proof) + Password Fixes

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:shimmer/shimmer.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage>
    with SingleTickerProviderStateMixin {
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
  Country _country = Country.parse("IN")!;

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

  // Glow animation controller
  late AnimationController _glowCtrl;
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    _passwordCtrl.addListener(_updateStrength);
    _confirmCtrl.addListener(() => setState(() {}));

    _phoneCtrl.addListener(_phoneFormatListener);

    // Pulse Glow Animation
    _glowCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _glowScale = Tween<double>(begin: 1.0, end: 1.35)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut));

    _glowOpacity = Tween<double>(begin: 0.20, end: 0.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut));
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
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Avatar Picker
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Country Picker
  // --------------------------------------------------------------------------
  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (c) => setState(() => _country = c),
    );
  }

  // --------------------------------------------------------------------------
  // DOB Picker
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Phone Formatting
  // --------------------------------------------------------------------------
  bool _phoneFormatting = false;

  void _phoneFormatListener() {
    if (_phoneFormatting) return;
    _phoneFormatting = true;

    final raw = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    String f;
    if (raw.length <= 3)
      f = raw;
    else if (raw.length <= 6)
      f = "${raw.substring(0, 3)} ${raw.substring(3)}";
    else if (raw.length <= 10)
      f = "${raw.substring(0, 3)} ${raw.substring(3, 6)} ${raw.substring(6)}";
    else
      f = raw;

    _phoneCtrl.value =
        TextEditingValue(text: f, selection: TextSelection.collapsed(offset: f.length));

    _phoneFormatting = false;
  }

  // --------------------------------------------------------------------------
  // Password Strength
  // --------------------------------------------------------------------------
  void _updateStrength() {
    final p = _passwordCtrl.text;

    if (p.isEmpty)
      _strengthColor = Colors.transparent;
    else if (p.length < 6)
      _strengthColor = Colors.red;
    else if (p.length < 10)
      _strengthColor = Colors.orange;
    else
      _strengthColor = Colors.green;

    setState(() {});
  }

  // --------------------------------------------------------------------------
  // Error & Submit
  // --------------------------------------------------------------------------
  void _err(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _scrollTo(GlobalKey key) async {
    if (key.currentContext == null) return;
    await Scrollable.ensureVisible(key.currentContext!,
        duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
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
      return _err("Please accept terms");
    }

    _err("Account created!");
  }

  // --------------------------------------------------------------------------
  // Tilt Effect
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Black Border Input Builder
  // --------------------------------------------------------------------------
  final BorderSide _blackBorder =
      const BorderSide(color: Colors.black87, width: 1.0);

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
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: _blackBorder),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: _blackBorder),
          suffixIcon: (hint == "Password")
              ? _passwordStrengthDot()
              : null,
        ),
      ),
    );
  }

  Widget _passwordStrengthDot() {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(right: 10),
      decoration:
          BoxDecoration(color: _strengthColor, shape: BoxShape.circle),
    );
  }

  // --------------------------------------------------------------------------
  // Animated Pulse Glow Gender Selector (Crash-Proof)
  // --------------------------------------------------------------------------
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
            final bool selected = (_selectedGender == g);

            return GestureDetector(
              onTap: () => setState(() {
                _selectedGender = g;
                _attemptSubmit = false;
              }),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Glow Behind Pill
                  if (selected)
                    AnimatedBuilder(
                      animation: _glowCtrl,
                      builder: (_, __) {
                        return Transform.scale(
                          scale: _glowScale.value,
                          child: Opacity(
                            opacity: _glowOpacity.value,
                            child: Container(
                              width: 120,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // Actual pill
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
                          width: 1.0),
                    ),
                    child: AnimatedScale(
                      scale: selected ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutBack,
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
            child: Text("Please select a gender",
                style: TextStyle(color: Colors.red.shade400)),
          ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Build UI
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _resetTilt(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCEEEE),

        appBar: AppBar(
          backgroundColor: Colors.white,
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
                        offset: Offset(0, 4))
                  ]),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: Colors.black87),
            ),
          ),
        ),

        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(18),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_tiltX * math.pi / 180)
              ..rotateY(_tiltY * math.pi / 180),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Create your account",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.pink.shade700)),
                const SizedBox(height: 10),

                Text("Already registered? Log in",
                    style: TextStyle(
                        color: Colors.pink.shade400,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),

                // CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18)),
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
                                gradient: LinearGradient(colors: [
                                  Colors.pink.shade50,
                                  Colors.purple.shade50
                                ]),
                                border:
                                    Border.all(color: Colors.white, width: 4),
                              ),
                              child: ClipOval(
                                child: _avatar == null
                                    ? Icon(Icons.camera_alt_outlined,
                                        size: 34,
                                        color: Colors.pink.shade300)
                                    : Image.file(_avatar!, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text("Upload profile photo",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14))
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Row 1
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
                            child: _input("Last name", _lastCtrl,
                                icon: Icons.person_outline),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Email
                      Container(
                        key: _emailKey,
                        child: _input("Email", _emailCtrl,
                            icon: Icons.email,
                            type: TextInputType.emailAddress),
                      ),

                      const SizedBox(height: 14),

                      // Row: Country + Phone
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _openCountryPicker,
                            child: Container(
                              height: 52,
                              width: 110,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: Colors.black87, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Text("+${_country.phoneCode}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87)),
                                  const SizedBox(width: 10),
                                  Text(_country.flagEmoji,
                                      style: const TextStyle(fontSize: 18)),
                                  const Spacer(),
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.black87),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _input("Phone number", _phoneCtrl,
                                  icon: Icons.phone,
                                  type: TextInputType.phone)),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // DOB
                      GestureDetector(
                        onTap: _pickDOB,
                        child: AbsorbPointer(
                          child: _input(
                              "DOB (YYYY-MM-DD)", _dobCtrl, icon: Icons.cake),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Password
                      Container(
                        key: _passwordKey,
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            _input("Password", _passwordCtrl,
                                icon: Icons.lock, obscure: _obscure),
                            Positioned(
                              right: 12,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _obscure = !_obscure),
                                child: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.black87,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Confirm Password
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          _input("Re-enter password", _confirmCtrl,
                              icon: Icons.lock, obscure: _obscureConfirm),
                          Positioned(
                            right: 12,
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
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
                          padding: const EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Passwords do not match",
                                style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Gender Pills (With Pulse Glow)
                      _genderSelector(),

                      const SizedBox(height: 20),

                      // Terms
                      Row(
                        children: [
                          Checkbox(
                            value: _agree,
                            onChanged: (v) =>
                                setState(() => _agree = v ?? false),
                          ),
                          const Expanded(
                              child: Text(
                                  "I agree to the Terms & Privacy Policy")),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Submit
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
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text("Contact support",
                        style: TextStyle(color: Colors.pink.shade400)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
