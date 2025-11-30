// create_account_page.dart
// FINAL VERSION — ALL BORDERS BLACK (Colors.black87), width: 1.0
// ------------------------------------------------------------------------------

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
  final List<String> _genderOptions = [
    "Male",
    "Female",
    "Other",
    "Prefer not to say"
  ];
  String? _selectedGender;
  bool _attemptSubmit = false;

  // UI State
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _agree = false;
  Color _strengthColor = Colors.transparent;

  // Tilt
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
    super.dispose();
  }

  // ------------------------------------------------------------------------------
  // Avatar
  // ------------------------------------------------------------------------------
  Future<void> _pickAvatar(ImageSource src) async {
    final picked = await _picker.pickImage(source: src, imageQuality: 85);
    if (picked != null) setState(() => _avatar = File(picked.path));
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
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
                leading: const Icon(Icons.delete),
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

  // ------------------------------------------------------------------------------
  // Country picker
  // ------------------------------------------------------------------------------
  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (c) => setState(() => _country = c),
    );
  }

  // ------------------------------------------------------------------------------
  // DOB
  // ------------------------------------------------------------------------------
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

  // ------------------------------------------------------------------------------
  // Phone formatting
  // ------------------------------------------------------------------------------
  bool _phoneFormatting = false;
  void _phoneFormatListener() {
    if (_phoneFormatting) return;

    _phoneFormatting = true;
    final raw = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    String f;

    if (raw.length <= 3) f = raw;
    else if (raw.length <= 6) f = "${raw.substring(0, 3)} ${raw.substring(3)}";
    else if (raw.length <= 10)
      f = "${raw.substring(0, 3)} ${raw.substring(3, 6)} ${raw.substring(6)}";
    else
      f = raw;

    _phoneCtrl.value = TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );

    _phoneFormatting = false;
  }

  // ------------------------------------------------------------------------------
  // Password strength
  // ------------------------------------------------------------------------------
  void _updateStrength() {
    String p = _passwordCtrl.text;
    if (p.isEmpty) _strengthColor = Colors.transparent;
    else if (p.length < 6) _strengthColor = Colors.red;
    else if (p.length < 10) _strengthColor = Colors.orange;
    else _strengthColor = Colors.green;

    setState(() {});
  }

  // ------------------------------------------------------------------------------
  // Submit + validation
  // ------------------------------------------------------------------------------
  void _err(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _scrollTo(GlobalKey key) async {
    if (key.currentContext == null) return;
    await Scrollable.ensureVisible(key.currentContext!,
        duration: const Duration(milliseconds: 350));
  }

  void _submit() {
    _attemptSubmit = true;

    if (_firstCtrl.text.isEmpty) {
      _scrollTo(_firstKey);
      return _err("Enter first name");
    }
    if (!_emailCtrl.text.contains("@")) {
      _scrollTo(_emailKey);
      return _err("Invalid email");
    }
    if (_passwordCtrl.text.length < 6) {
      _scrollTo(_passwordKey);
      return _err("Password too short");
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      return _err("Passwords do not match");
    }
    if (_selectedGender == null) {
      setState(() {});
      return _err("Select gender");
    }
    if (!_agree) {
      return _err("Please accept terms");
    }

    _err("Account created!");
  }

  // ------------------------------------------------------------------------------
  // Tilt
  // ------------------------------------------------------------------------------
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

  // ------------------------------------------------------------------------------
  // Borders (Black everywhere)
  // ------------------------------------------------------------------------------
  final BorderSide _blackBorder =
      const BorderSide(color: Colors.black87, width: 1.0);

  // ------------------------------------------------------------------------------
  // Gender dropdown — Black border
  // ------------------------------------------------------------------------------
  Widget _genderDropdown() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (_selectedGender == null && _attemptSubmit)
              ? Colors.red
              : Colors.black87,
          width: 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedGender,
          hint: Row(
            children: [
              Icon(Icons.person_outline, color: Colors.pink.shade300),
              const SizedBox(width: 10),
              const Text("Gender"),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
          style: const TextStyle(color: Colors.black87),

          selectedItemBuilder: (_) {
            return _genderOptions.map((item) {
              return Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.pink.shade300),
                  const SizedBox(width: 10),
                  Text(item),
                ],
              );
            }).toList();
          },

          items: _genderOptions.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item,
                  style:
                      const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              _selectedGender = value;
              _attemptSubmit = false;
            });
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------------
  // Country box — Black border
  // ------------------------------------------------------------------------------
  Widget _countryBox() {
    return GestureDetector(
      onTap: _openCountryPicker,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black87, width: 1.0),
        ),
        child: Row(
          children: [
            Text("+${_country.phoneCode}",
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
            const SizedBox(width: 10),
            Text(_country.flagEmoji,
                style: const TextStyle(fontSize: 18)),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------------
  // Input field — Black border
  // ------------------------------------------------------------------------------
  Widget _input(String hint, TextEditingController controller,
      {IconData? icon, TextInputType? type, bool obscure = false}) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.pink.shade300)
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: _blackBorder,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: _blackBorder,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: _blackBorder,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------------
  // Build UI
  // ------------------------------------------------------------------------------
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
                ],
              ),
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
                      color: Colors.pink.shade700,
                    )),
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
                                      Border.all(color: Colors.white, width: 4)),
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
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14))
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

                      // Row 2 — Email
                      Container(
                        key: _emailKey,
                        child: _input("Email", _emailCtrl,
                            icon: Icons.email,
                            type: TextInputType.emailAddress),
                      ),

                      const SizedBox(height: 14),

                      // Row 3 — Country + Phone
                      Row(
                        children: [
                          SizedBox(width: 110, child: _countryBox()),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _input("Phone number", _phoneCtrl,
                                icon: Icons.phone,
                                type: TextInputType.phone),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Row 4 — DOB + Gender
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDOB,
                              child: AbsorbPointer(
                                child: _input(
                                  "DOB (YYYY-MM-DD)",
                                  _dobCtrl,
                                  icon: Icons.cake,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _genderDropdown()),
                        ],
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
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
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
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Re-enter Password
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          _input("Re-enter password", _confirmCtrl,
                              icon: Icons.lock, obscure: _obscureConfirm),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
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
                          )
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Terms
                      Row(
                        children: [
                          Checkbox(
                            value: _agree,
                            onChanged: (v) =>
                                setState(() => _agree = v ?? false),
                          ),
                          const Expanded(
                              child: Text("I agree to the Terms & Privacy"))
                        ],
                      ),

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

                const SizedBox(height: 20),

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
      ),
    );
  }
}
