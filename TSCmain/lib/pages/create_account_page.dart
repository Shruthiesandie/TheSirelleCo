// Add these to pubspec.yaml if you haven't already:
//   image_picker: ^1.0.7
//   country_picker: ^2.0.21
//   shimmer: ^3.0.0

import 'dart:io';
import 'dart:math';
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
  // controllers
  final TextEditingController _firstCtrl = TextEditingController();
  final TextEditingController _lastCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();

  // profile image
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // gender & country
  String _gender = "Male";
  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse("IN") ?? Country(
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
  }

  // subtle UI physics (tilt)
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  // focus tracking for glow
  String _focusedField = "";

  // UI toggles
  bool _showShimmer = true;
  bool _obscure = true;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  // --------------- Image Picking ----------------
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image error: $e")),
      );
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take photo"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from gallery"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_image != null)
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text("Remove photo"),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _image = null);
                  },
                ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  // --------------- Date of Birth ---------------
  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 20, now.month, now.day);
    final firstDate = DateTime(now.year - 100);
    final lastDate = DateTime(now.year - 10);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFF6FAF),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFB97BFF)),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      _dobCtrl.text = "${picked.year.toString().padLeft(4, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  // --------------- Country Picker ---------------
  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() => _selectedCountry = country);
        // prefill phone country code if empty
        if (_phoneCtrl.text.isEmpty) {
          _phoneCtrl.text = "+${country.phoneCode}";
        } else if (!_phoneCtrl.text.startsWith("+")) {
          _phoneCtrl.text = "+${country.phoneCode} ${_phoneCtrl.text}";
        }
      },
    );
  }

  // --------------- Tilt Handling ---------------
  void _onPointerMove(PointerEvent e) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = (e.position.dx - center.dx) / center.dx;
    final dy = (e.position.dy - center.dy) / center.dy;
    // clamp and scale
    const maxDeg = 6.0;
    setState(() {
      _tiltY = (dx).clamp(-1.0, 1.0) * maxDeg;
      _tiltX = (-dy).clamp(-1.0, 1.0) * maxDeg;
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  // --------------- Register (placeholder) ---------------
  void _onRegister() {
    // Basic validation
    if (_firstCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill name and email.")),
      );
      return;
    }
    // Fake submit
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created (demo).")),
    );
    // Navigate or do actual signup here...
  }

  // --------------- Focus helpers ---------------
  void _onFocus(String field) {
    setState(() => _focusedField = field);
  }

  void _onUnfocus() {
    setState(() => _focusedField = "");
  }

  // --------------- UI building helpers ---------------
  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _decor(String hint, {IconData? icon}) {
    final bool focused = _focusedField == hint;
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.pink.shade300) : null,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: focused ? Colors.pink.shade300 : Colors.grey.shade300),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Focus(
      onFocusChange: (hasFocus) => hasFocus ? _onFocus(hint) : _onUnfocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: _focusedField == hint
              ? [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 6),
                  )
                ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          onTap: onTap,
          decoration: _decor(hint, icon: icon),
        ),
      ),
    );
  }

  Widget _profileAvatar() {
    final radius = 56.0;
    return GestureDetector(
      onTap: _showImageOptions,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, val, child) {
            return Transform.scale(
              scale: 0.9 + 0.1 * val,
              child: child,
            );
          },
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _image == null
                  ? LinearGradient(
                      colors: [Colors.pink.shade50, Colors.purple.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                )
              ],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: ClipOval(
              child: _image == null
                  ? Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 34,
                          color: Colors.pink.shade300,
                        ),
                      ),
                    )
                  : Image.file(_image!, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderChip(String label, IconData icon, Color color) {
    final bool sel = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(0.14) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: sel ? color : Colors.grey.shade300, width: sel ? 1.6 : 1),
          boxShadow: sel
              ? [
                  BoxShadow(color: color.withOpacity(0.18), blurRadius: 14, offset: const Offset(0, 8))
                ]
              : [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 6))
                ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: sel ? color : Colors.black54),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: sel ? color : Colors.black87, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // --------------- Build ---------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Listener(
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _resetTilt(),
      onPointerCancel: (_) => _resetTilt(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCEEEE),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_tiltX * pi / 180)
                  ..rotateY(_tiltY * pi / 180),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Create your account",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.pinkAccent),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Join to get rewards, personalized picks and exclusive offers.",
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),

              // Card like glass area
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_tiltX * pi / 180)
                  ..rotateY(_tiltY * pi / 180),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.80),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.7)),
                    boxShadow: [
                      BoxShadow(color: Colors.pink.shade100.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // avatar + small hint
                      Row(
                        children: [
                          _profileAvatar(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Profile photo", style: TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                const Text("Tap to upload or take a photo", style: TextStyle(color: Colors.black54, fontSize: 12)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        elevation: 0,
                                        side: BorderSide(color: Colors.pink.shade100),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onPressed: _showImageOptions,
                                      icon: Icon(Icons.upload_file, color: Colors.pink.shade300),
                                      label: const Text("Upload", style: TextStyle(color: Colors.black87)),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () => setState(() => _image = null),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.pink.shade300,
                                        side: BorderSide(color: Colors.pink.shade50),
                                      ),
                                      child: const Text("Remove"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 18),

                      // name fields
                      Row(
                        children: [
                          Expanded(child: _field(controller: _firstCtrl, hint: "First name", icon: Icons.person)),
                          const SizedBox(width: 12),
                          Expanded(child: _field(controller: _lastCtrl, hint: "Last name", icon: Icons.person_outline)),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // email
                      _field(controller: _emailCtrl, hint: "Email address", icon: Icons.email, keyboardType: TextInputType.emailAddress),

                      const SizedBox(height: 12),

                      // phone + country
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
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text("+${_selectedCountry.phoneCode}", style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 24,
                                    child: Image.asset(
                                      'icons/flags/png/${_selectedCountry.countryCode.toLowerCase()}.png',
                                      package: 'country_icons',
                                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.keyboard_arrow_down, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _field(controller: _phoneCtrl, hint: "Phone number", keyboardType: TextInputType.phone)),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // password + dob
                      Row(
                        children: [
                          Expanded(child: _field(controller: _passwordCtrl, hint: "Password", obscure: _obscure, icon: Icons.lock)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDOB,
                              child: AbsorbPointer(
                                child: _field(controller: _dobCtrl, hint: "Date of birth (YYYY-MM-DD)", icon: Icons.cake),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // gender selector + small note
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 10,
                          children: [
                            _genderChip("Male", Icons.male, Colors.blue),
                            _genderChip("Female", Icons.female, Colors.pink),
                            _genderChip("Other", Icons.transgender, Colors.purple),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // terms
                      Row(
                        children: [
                          Checkbox(value: true, onChanged: (_) {}),
                          Expanded(child: Text("I agree to the Terms & Privacy policy", style: TextStyle(color: Colors.black54))),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // register button with shimmer
                      SizedBox(
                        width: double.infinity,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _onRegister,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.pinkAccent.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10)),
                                ],
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: _showShimmer
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.white.withOpacity(0.85),
                                      highlightColor: Colors.white.withOpacity(0.45),
                                      child: const Center(
                                        child: Text(
                                          "CREATE ACCOUNT",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1),
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: Text(
                                        "CREATE ACCOUNT",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // already registered
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already registered? Log in", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
