// create_account_page.dart
//
// A single-file, ready-to-copy Create Account page.
// - Pinteresty, pink-and-white aesthetic
// - Rotating 3D gender chips (option C chosen)
// - Avatar upload (camera/gallery) + circular preview
// - Country picker (no external flag asset required — uses emoji)
// - DOB picker, phone auto-format, password strength dot, re-enter password
// - Show/hide password, smooth scroll-to-error, spacious layout
// - Subtle tilt & micro-animations (no risky anim controller math)
// - No usage of country_icons assets (avoids missing-asset crash)
//
// Make sure you have these dependencies in pubspec.yaml:
//   image_picker: ^1.0.7
//   country_picker: ^2.0.21
//   shimmer: ^3.0.0
//
// Note: add permissions for camera/gallery on Android/iOS as usual.

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

class _CreateAccountPageState extends State<CreateAccountPage> {
  // Controllers & keys
  final _scrollController = ScrollController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  // Focus nodes for nicer focus handling
  final _firstFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // GlobalKeys to scroll to fields on error (unique keys)
  final _firstKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();

  // Avatar
  File? _avatar;
  final ImagePicker _picker = ImagePicker();

  // Country (default to India)
  Country _country = Country.parse("IN") ?? Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    example: 'India',
    displayName: 'India',
    displayNameNoCountryCode: 'India',
    e164Key: '',
    name: 'India',
  );

  // Gender slider (rotating 3D chips)
  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  int _genderIndex = 0;

  // Tiny UI state
  bool _obscure = true;
  bool _obscureConfirm = true;
  Color _strengthColor = Colors.red;
  bool _agree = false;
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_updateStrength);
    _phoneCtrl.addListener(_phoneFormatListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _dobCtrl.dispose();
    _firstFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ---------------- Avatar ----------------
  Future<void> _pickAvatar(ImageSource src) async {
    try {
      final picked = await _picker.pickImage(source: src, imageQuality: 85, maxWidth: 1200);
      if (picked != null) {
        setState(() => _avatar = File(picked.path));
      }
    } catch (_) {}
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) => SafeArea(
        child: Wrap(
          children: [
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
                leading: const Icon(Icons.delete_forever),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.pop(c);
                  setState(() => _avatar = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- Country ----------------
  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (c) {
        setState(() => _country = c);
        if (!_phoneCtrl.text.startsWith('+')) {
          _phoneCtrl.text = '+${c.phoneCode} ';
          _phoneCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _phoneCtrl.text.length));
        }
      },
    );
  }

  // ---------------- DOB ----------------
  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF6FAF)),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      _dobCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
    }
  }

  // ---------------- Phone formatting ----------------
  bool _phoneFormatting = false;
  void _phoneFormatListener() {
    if (_phoneFormatting) return;
    _phoneFormatting = true;
    final raw = _phoneCtrl.text;
    final numbers = raw.replaceAll(RegExp(r'\D'), '');
    String formatted;
    if (numbers.length <= 3) formatted = numbers;
    else if (numbers.length <= 6) formatted = "${numbers.substring(0,3)} ${numbers.substring(3)}";
    else if (numbers.length <= 10) formatted = "${numbers.substring(0,3)} ${numbers.substring(3,6)} ${numbers.substring(6)}";
    else formatted = numbers;
    // keep cursor at end — simpler and safe
    _phoneCtrl.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
    _phoneFormatting = false;
  }

  // ---------------- Password strength ----------------
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

  // ---------------- Submit & scroll to error ----------------
  Future<void> _scrollToKey(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 360), curve: Curves.easeOut);
  }

  void _submit() {
    // Simple validations with smooth scrolling
    if (_firstCtrl.text.trim().isEmpty) {
      _scrollToKey(_firstKey);
      _shakeSnack('Please enter your first name');
      return;
    }
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      _scrollToKey(_emailKey);
      _shakeSnack('Please enter a valid email');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      _scrollToKey(_passwordKey);
      _shakeSnack('Password too short');
      return;
    }
    if (_confirmCtrl.text != _passwordCtrl.text) {
      _shakeSnack('Passwords do not match');
      return;
    }
    if (!_agree) {
      _shakeSnack('Please accept Terms & Privacy');
      return;
    }

    // Demo success
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created — demo')));
  }

  void _shakeSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  // ---------------- Tilt micro-interaction ----------------
  void _onPointerMove(PointerEvent e) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width/2, size.height/2);
    final dx = (e.position.dx - center.dx) / center.dx;
    final dy = (e.position.dy - center.dy) / center.dy;
    setState(() {
      _tiltY = (dx*6).clamp(-8.0, 8.0);
      _tiltX = (-dy*6).clamp(-8.0, 8.0);
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0; _tiltY = 0;
    });
  }

  // ---------------- Rotating chip widget used below ----------------
  Widget _rotatingChip(String label, int index) {
    final bool selected = index == _genderIndex;
    final double rotationY = selected ? 0.0 : (index < _genderIndex ? -0.18 : 0.18);
    return GestureDetector(
      onTap: () => setState(() => _genderIndex = index),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: selected ? 1.0 : 0.88, end: selected ? 1.0 : 0.88),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(rotationY)
              ..scale(scale, scale),
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)])
                    : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade300),
                boxShadow: selected
                    ? [BoxShadow(color: Colors.pink.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 8))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 6))],
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- Layout ----------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Listener(
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _resetTilt(),
      onPointerCancel: (_) => _resetTilt(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCEEEE),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            ),
          ),
        ),

        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_tiltX * (math.pi/180))
              ..rotateY(_tiltY * (math.pi/180)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text('Create your account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.pink.shade700),
                ),
                const SizedBox(height: 6),

                // Already registered placed under title (clean)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('Already registered? Log in',
                    style: TextStyle(color: Colors.pink.shade400, fontWeight: FontWeight.w700),
                  ),
                ),

                const SizedBox(height: 8),
                Text('Join to get rewards, personalized picks & exclusive offers.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),

                const SizedBox(height: 18),

                // Glass card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.6)),
                    boxShadow: [BoxShadow(color: Colors.pink.shade50.withOpacity(0.9), blurRadius: 28, offset: const Offset(0,12))],
                  ),
                  child: Column(
                    children: [
                      // Avatar row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showAvatarOptions,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _avatar == null
                                    ? LinearGradient(colors: [Colors.pink.shade50, Colors.purple.shade50])
                                    : null,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.12), blurRadius: 18, offset: const Offset(0,10))],
                              ),
                              child: ClipOval(
                                child: _avatar == null
                                    ? Center(child: Icon(Icons.camera_alt_outlined, size: 36, color: Colors.pink.shade300))
                                    : Image.file(_avatar!, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Profile hint and actions
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Profile photo', style: TextStyle(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 6),
                                Text('Tap to upload or take photo', style: TextStyle(color: Colors.black54, fontSize: 13)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        elevation: 0,
                                        side: BorderSide(color: Colors.pink.shade50),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onPressed: _showAvatarOptions,
                                      icon: Icon(Icons.upload_file, color: Colors.pink.shade300),
                                      label: const Text('Upload', style: TextStyle(color: Colors.black87)),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () => setState(() => _avatar = null),
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.pink.shade300),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 18),

                      // FIRST & LAST (with unique key for scrolling)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              key: _firstKey,
                              child: _inputField(controller: _firstCtrl, hint: 'First name', icon: Icons.person),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _inputField(controller: _lastCtrl, hint: 'Last name', icon: Icons.person_outline)),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Email
                      Container(
                        key: _emailKey,
                        child: _inputField(controller: _emailCtrl, hint: 'Email address', icon: Icons.email, keyboardType: TextInputType.emailAddress),
                      ),

                      const SizedBox(height: 12),

                      // Phone + Country
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _openCountryPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Text('+${_country.phoneCode}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 8),
                                  // Use emoji flag (safe)
                                  Text(_country.flagEmoji, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _inputField(controller: _phoneCtrl, hint: 'Phone number', keyboardType: TextInputType.phone)),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // DOB + Password row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDOB,
                              child: AbsorbPointer(child: _inputField(controller: _dobCtrl, hint: 'Date of birth (YYYY-MM-DD)', icon: Icons.cake)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              key: _passwordKey,
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  _inputField(controller: _passwordCtrl, hint: 'Password', obscure: _obscure),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // strength dot
                                      Container(width: 12, height: 12, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(shape: BoxShape.circle, color: _strengthColor)),
                                      GestureDetector(
                                        onTap: () => setState(() => _obscure = !_obscure),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.black45),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Confirm password
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          _inputField(controller: _confirmCtrl, hint: 'Re-enter password', obscure: _obscureConfirm),
                          GestureDetector(
                            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.black45),
                            ),
                          ),
                        ],
                      ),

                      if (_confirmCtrl.text.isNotEmpty && _confirmCtrl.text != _passwordCtrl.text)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Passwords do not match', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
                          ),
                        ),

                      const SizedBox(height: 18),

                      // Rotating 3D gender chips area (spacious)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gender', style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(_genders.length, (i) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _rotatingChip(_genders[i], i),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Terms + Agree
                      Row(
                        children: [
                          Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
                          Expanded(child: Text('I agree to the Terms & Privacy policy', style: TextStyle(color: Colors.black54))),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Register button (shimmer + hover feedback)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _submit,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            height: 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
                              boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.28), blurRadius: 20, offset: const Offset(0,10))],
                            ),
                            child: Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor: Colors.white70,
                              child: const Center(
                                child: Text('CREATE ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Small footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Need help?', style: TextStyle(color: Colors.black54)),
                    const SizedBox(width: 8),
                    TextButton(onPressed: () {}, child: Text('Contact support', style: TextStyle(color: Colors.pink.shade400)))
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Small helper to render input fields cleanly ----------------
  Widget _inputField({required TextEditingController controller, required String hint, IconData? icon, TextInputType? keyboardType, bool obscure = false}) {
    final focused = FocusScope.of(context).focusedChild == null ? false : false;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.pink.shade300) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}
