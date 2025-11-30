// Add these to pubspec.yaml:
// image_picker: ^1.0.7
// country_picker: ^2.0.21
// shimmer: ^3.0.0
// country_icons: ^2.0.2

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

  // gender dropdown
  String? _gender;

  // country picker
  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse("IN");
  }

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

  // -------------------------------------------------------
  // IMAGE PICKER
  // -------------------------------------------------------
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 900,
      );
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {}
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_image != null)
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text("Remove photo"),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _image = null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------
  // DATE PICKER
  // -------------------------------------------------------
  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 12),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6FAF),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFB97BFF),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _dobCtrl.text =
          "${picked.year}-${picked.month.toString().padLeft(2, "0")}-${picked.day.toString().padLeft(2, "0")}";
    }
  }

  // -------------------------------------------------------
  // COUNTRY PICKER
  // -------------------------------------------------------
  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (c) {
        setState(() => _selectedCountry = c);
        if (!_phoneCtrl.text.startsWith("+")) {
          _phoneCtrl.text = "+${c.phoneCode} ";
        }
      },
    );
  }

  // -------------------------------------------------------
  // TILT ANIMATION
  // -------------------------------------------------------
  double _tiltX = 0;
  double _tiltY = 0;

  void _onPointerMove(PointerEvent e) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);

    final dx = (e.position.dx - center.dx) / center.dx;
    final dy = (e.position.dy - center.dy) / center.dy;

    setState(() {
      _tiltY = dx * 5;
      _tiltX = -dy * 5;
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  // -------------------------------------------------------
  // FIELD DECOR
  // -------------------------------------------------------
  InputDecoration _decor(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint,
      {TextInputType? type, bool obscure = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      decoration: _decor(hint),
    );
  }

  // -------------------------------------------------------
  // PROFILE AVATAR
  // -------------------------------------------------------
  Widget _profileAvatar() {
    return GestureDetector(
      onTap: _showImageOptions,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.pink.shade50,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.25),
              blurRadius: 25,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipOval(
          child: _image == null
              ? Icon(Icons.camera_alt, size: 40, color: Colors.pink.shade300)
              : Image.file(_image!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // REGISTER
  // -------------------------------------------------------
  void _register() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created (demo).")),
    );
  }

  // -------------------------------------------------------
  // BUILD
  // -------------------------------------------------------
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: Colors.black),
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Transform(
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
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.pinkAccent),
                ),
                const SizedBox(height: 6),
                Text(
                  "Earn rewards, personalized outfits and more.",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),

                const SizedBox(height: 20),

                // CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.pink.shade100.withOpacity(0.2),
                          blurRadius: 25,
                          offset: const Offset(0, 12))
                    ],
                  ),
                  child: Column(
                    children: [
                      // PROFILE
                      Center(child: _profileAvatar()),
                      const SizedBox(height: 20),

                      // FIRST / LAST NAME
                      Row(
                        children: [
                          Expanded(child: _field(_firstCtrl, "First name")),
                          const SizedBox(width: 12),
                          Expanded(child: _field(_lastCtrl, "Last name")),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // EMAIL
                      _field(_emailCtrl, "Email", type: TextInputType.emailAddress),
                      const SizedBox(height: 12),

                      // PHONE + COUNTRY
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _openCountryPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Text("+${_selectedCountry.phoneCode}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 26,
                                    child: Image.asset(
                                      'icons/flags/png/${_selectedCountry.countryCode.toLowerCase()}.png',
                                      package: 'country_icons',
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(_phoneCtrl, "Phone number",
                                type: TextInputType.phone),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // PASSWORD
                      _field(_passwordCtrl, "Password", obscure: true),
                      const SizedBox(height: 12),

                      // DOB
                      GestureDetector(
                        onTap: _pickDOB,
                        child: AbsorbPointer(
                          child: _field(_dobCtrl, "Date of birth"),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // GENDER DROPDOWN
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: _decor("Gender"),
                        items: const [
                          DropdownMenuItem(
                              value: "Male", child: Text("Male")),
                          DropdownMenuItem(
                              value: "Female", child: Text("Female")),
                          DropdownMenuItem(
                              value: "Other", child: Text("Other")),
                        ],
                        onChanged: (v) => setState(() => _gender = v),
                      ),

                      const SizedBox(height: 20),

                      // REGISTER BUTTON
                      GestureDetector(
                        onTap: _register,
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF6FAF),
                                Color(0xFFB97BFF)
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.pinkAccent.withOpacity(0.35),
                                  blurRadius: 22,
                                  offset: Offset(0, 10))
                            ],
                          ),
                          child: Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.white70,
                            child: const Center(
                              child: Text(
                                "CREATE ACCOUNT",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8),
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
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Already registered? Log in",
                      style: TextStyle(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
