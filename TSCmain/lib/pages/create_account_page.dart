// create_account_page.dart
//
// Clean, stable version
// - No _onPhoneChanged error
// - No _orbController error
// - ALL fields are on SEPARATE LINES
// - Phone auto-format works
// - Gender rotating chips intact
// - Avatar upload intact
// - DOB picker intact
// - Smooth scroll-to-error intact
// ------------------------------------------------------------

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
  // Controllers
  final _scrollController = ScrollController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  // Focus nodes
  final _firstKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();

  // Avatar
  File? _avatar;
  final ImagePicker _picker = ImagePicker();

  // Country
  Country _country = Country.parse("IN")!;

  // Gender
  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  int _genderIndex = 0;

  // UI state
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _agree = false;
  Color _strengthColor = Colors.transparent;

  double _tiltX = 0;
  double _tiltY = 0;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_updateStrength);
    _phoneCtrl.addListener(_phoneFormatListener); // correct listener
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
    super.dispose();
  }

  // ---------------- Avatar ----------------
  Future<void> _pickAvatar(ImageSource src) async {
    final picked = await _picker.pickImage(source: src, imageQuality: 85);
    if (picked != null) setState(() => _avatar = File(picked.path));
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (c) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Take photo"),
            onTap: () {
              Navigator.pop(c);
              _pickAvatar(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Choose from gallery"),
            onTap: () {
              Navigator.pop(c);
              _pickAvatar(ImageSource.gallery);
            },
          ),
          if (_avatar != null)
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text("Remove photo"),
              onTap: () {
                Navigator.pop(c);
                setState(() => _avatar = null);
              },
            ),
        ]),
      ),
    );
  }

  // ---------------- Country picker ----------------
  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (c) {
        setState(() => _country = c);
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
    );

    if (picked != null) {
      _dobCtrl.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // ---------------- Phone formatting ----------------
  bool _phoneFormatting = false;
  void _phoneFormatListener() {
    if (_phoneFormatting) return;

    _phoneFormatting = true;
    String raw = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');

    String f;
    if (raw.length <= 3) {
      f = raw;
    } else if (raw.length <= 6) {
      f = "${raw.substring(0, 3)} ${raw.substring(3)}";
    } else if (raw.length <= 10) {
      f = "${raw.substring(0, 3)} ${raw.substring(3, 6)} ${raw.substring(6)}";
    } else {
      f = raw;
    }

    _phoneCtrl.value = TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );

    _phoneFormatting = false;
  }

  // ---------------- Password strength ----------------
  void _updateStrength() {
    String p = _passwordCtrl.text;
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

  // ---------------- Scroll to error ----------------
  Future<void> _scrollToKey(GlobalKey key) async {
    if (key.currentContext == null) return;
    await Scrollable.ensureVisible(key.currentContext!,
        duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
  }

  void _submit() {
    if (_firstCtrl.text.trim().isEmpty) {
      _scrollToKey(_firstKey);
      _err("Please enter first name");
      return;
    }
    if (!_emailCtrl.text.contains("@")) {
      _scrollToKey(_emailKey);
      _err("Invalid email");
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      _scrollToKey(_passwordKey);
      _err("Password too short");
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      _err("Passwords do not match");
      return;
    }
    if (!_agree) {
      _err("Please accept terms");
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Account created")));
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- Tilt effect ----------------
  void _onPointerMove(PointerEvent e) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = (e.position.dx - center.dx) / center.dx;
    final dy = (e.position.dy - center.dy) / center.dy;

    setState(() {
      _tiltY = (dx * 6).clamp(-8.0, 8.0);
      _tiltX = (-dy * 6).clamp(-8.0, 8.0);
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  // ---------------- Rotating gender chip ----------------
  Widget _chip(String label, int index) {
    final bool selected = index == _genderIndex;
    final double rotateY = selected ? 0 : (index < _genderIndex ? -0.15 : 0.15);

    return GestureDetector(
      onTap: () => setState(() => _genderIndex = index),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(rotateY),
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)])
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: selected ? Colors.transparent : Colors.grey.shade300),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: Colors.pink.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 4))
                  ],
          ),
          child: Text(
            label,
            style:
                TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // ---------------- Build UI ----------------
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
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: Colors.black),
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

                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text("Already registered? Log in",
                      style: TextStyle(
                          color: Colors.pink.shade400,
                          fontWeight: FontWeight.w700)),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(children: [
                    // Avatar
                    Row(children: [
                      GestureDetector(
                        onTap: _showAvatarOptions,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _avatar == null
                                ? LinearGradient(colors: [
                                    Colors.pink.shade50,
                                    Colors.purple.shade50
                                  ])
                                : null,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: ClipOval(
                            child: _avatar == null
                                ? Icon(Icons.camera_alt_outlined,
                                    size: 36, color: Colors.pink.shade300)
                                : Image.file(_avatar!, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Profile photo",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text("Tap to upload or take photo",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                            ]),
                      )
                    ]),

                    const SizedBox(height: 20),

                    // First name
                    Container(
                      key: _firstKey,
                      child: _input("First name", _firstCtrl, Icons.person),
                    ),
                    const SizedBox(height: 14),

                    // Last name
                    _input("Last name", _lastCtrl, Icons.person_outline),
                    const SizedBox(height: 14),

                    // Email
                    Container(
                        key: _emailKey,
                        child: _input("Email address", _emailCtrl,
                            Icons.email, TextInputType.emailAddress)),
                    const SizedBox(height: 14),

                    // Country
                    GestureDetector(
                      onTap: _openCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(children: [
                          Text("+${_country.phoneCode}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 10),
                          Text(_country.flagEmoji, style:
                              const TextStyle(fontSize: 18)),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down)
                        ]),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Phone
                    _input("Phone number", _phoneCtrl, Icons.phone,
                        TextInputType.phone),
                    const SizedBox(height: 14),

                    // DOB
                    GestureDetector(
                      onTap: _pickDOB,
                      child: AbsorbPointer(
                        child: _input("Date of birth (YYYY-MM-DD)", _dobCtrl,
                            Icons.cake),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password
                    Container(
                      key: _passwordKey,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          _input("Password", _passwordCtrl, Icons.lock,
                              null, _obscure),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _strengthColor,
                              ),
                            ),
                            GestureDetector(
                                onTap: () => setState(
                                    () => _obscure = !_obscure),
                                child: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                    color: Colors.black45))
                          ])
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Confirm password
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        _input("Re-enter password", _confirmCtrl, Icons.lock,
                            null, _obscureConfirm),
                        GestureDetector(
                            onTap: () => setState(() =>
                                _obscureConfirm = !_obscureConfirm),
                            child: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Colors.black45))
                      ],
                    ),

                    if (_confirmCtrl.text.isNotEmpty &&
                        _confirmCtrl.text != _passwordCtrl.text)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Passwords do not match",
                                style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.w600))),
                      ),

                    const SizedBox(height: 20),

                    // Gender
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Gender",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                      _genders.length,
                                      (i) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 12),
                                          child: _chip(_genders[i], i))),
                                ),
                              )
                            ])),
                    const SizedBox(height: 20),

                    // Agree
                    Row(children: [
                      Checkbox(
                          value: _agree,
                          onChanged: (v) =>
                              setState(() => _agree = v ?? false)),
                      Expanded(
                          child: Text(
                              "I agree to the Terms & Privacy policy",
                              style: TextStyle(color: Colors.black54)))
                    ]),

                    const SizedBox(height: 14),

                    // Button
                    GestureDetector(
                      onTap: _submit,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
                        ),
                        child: Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.white70,
                            child: const Center(
                                child: Text("CREATE ACCOUNT",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900)))),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 20),
                Center(
                    child: TextButton(
                        onPressed: () {},
                        child: Text("Contact support",
                            style:
                                TextStyle(color: Colors.pink.shade400))))
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Input helper ----------------
  Widget _input(String hint, TextEditingController controller,
      IconData icon, [TextInputType? type, bool obscure = false]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.pink.shade300),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}
