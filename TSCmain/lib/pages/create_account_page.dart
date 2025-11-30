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
  final TextEditingController _confirmCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();

  // scroll controller for jump-to-error
  final ScrollController _scrollController = ScrollController();

  // image picker
  File? _image;
  final _picker = ImagePicker();

  // gender slider (G1)
  int _genderIndex = 0; // 0=male, 1=female, 2=other
  final List<String> _genders = ["Male", "Female", "Other"];

  // country
  late Country _country;

  // tilt
  double _tiltX = 0;
  double _tiltY = 0;

  // show password or not
  bool _showPass = false;
  bool _showConfirmPass = false;

  // password strength dot
  Color _strengthDot = Colors.red;

  @override
  void initState() {
    super.initState();
    _country = Country.parse("IN");

    _passwordCtrl.addListener(_checkPasswordStrength);
    _confirmCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // PASSWORD STRENGTH DOT
  // ---------------------------------------------------------
  void _checkPasswordStrength() {
    String p = _passwordCtrl.text;

    if (p.length < 6) {
      _strengthDot = Colors.red;
    } else if (p.length < 10) {
      _strengthDot = Colors.orange;
    } else {
      _strengthDot = Colors.green;
    }
    setState(() {});
  }

  // ---------------------------------------------------------
  // IMAGE PICKER
  // ---------------------------------------------------------
  Future<void> _pickImage(ImageSource src) async {
    final img = await _picker.pickImage(source: src, imageQuality: 85);
    if (img != null) {
      setState(() => _image = File(img.path));
    }
  }

  void _imageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
            ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
            if (_image != null)
              ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text("Remove"),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _image = null);
                  }),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // AUTO PHONE FORMAT
  // ---------------------------------------------------------
  String _formatPhone(String input) {
    final numbers = input.replaceAll(RegExp(r'\D'), '');

    if (numbers.length <= 3) return numbers;
    if (numbers.length <= 7) return "${numbers.substring(0, 3)} ${numbers.substring(3)}";
    if (numbers.length <= 10) {
      return "${numbers.substring(0, 3)} "
          "${numbers.substring(3, 6)} "
          "${numbers.substring(6)}";
    }
    return numbers;
  }

  // ---------------------------------------------------------
  // DOB
  // ---------------------------------------------------------
  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year - 10),
      builder: (_, child) => Theme(
        data: ThemeData(
            colorScheme:
                ColorScheme.light(primary: Colors.pink.shade300)),
        child: child!,
      ),
    );

    if (picked != null) {
      _dobCtrl.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  // ---------------------------------------------------------
  // GENDER SLIDER (G1)
  // ---------------------------------------------------------
  Widget _genderSlider() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          // PINK SLIDING PILL
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: [
              Alignment.centerLeft,
              Alignment.center,
              Alignment.centerRight
            ][_genderIndex],
            child: Container(
              width: 100,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                ),
              ),
            ),
          ),
          // LABELS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _genders.length,
              (i) => GestureDetector(
                onTap: () => setState(() => _genderIndex = i),
                child: SizedBox(
                  width: 100,
                  child: Center(
                    child: Text(
                      _genders[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _genderIndex == i
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // FIELD
  // ---------------------------------------------------------
  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );

  // ---------------------------------------------------------
  // SUBMIT + SCROLL TO ERROR
  // ---------------------------------------------------------
  void _submit() {
    if (_firstCtrl.text.trim().isEmpty) {
      _scrollTo(_firstCtrl);
      return;
    }
    if (_emailCtrl.text.trim().isEmpty) {
      _scrollTo(_emailCtrl);
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      _scrollTo(_passwordCtrl);
      return;
    }
    if (_confirmCtrl.text != _passwordCtrl.text) {
      _scrollTo(_confirmCtrl);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Account created (demo)"),
      ),
    );
  }

  void _scrollTo(TextEditingController ctrl) {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (e) {
        final size = MediaQuery.of(context).size;
        final center = Offset(size.width / 2, size.height / 2);
        setState(() {
          _tiltY = ((e.position.dx - center.dx) / center.dx) * 4;
          _tiltX = ((center.dy - e.position.dy) / center.dy) * 4;
        });
      },
      onPointerUp: (_) => setState(() {
        _tiltX = 0;
        _tiltY = 0;
      }),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCEEEE),

        // ---------------- TOP BAR ----------------
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.7),
                borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, .001)
              ..rotateX(_tiltX * pi / 180)
              ..rotateY(_tiltY * pi / 180),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- TITLE ----------
                const Text(
                  "Create your account",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.pinkAccent),
                ),

                const SizedBox(height: 6),

                // LOGIN BELOW TITLE
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Already registered? Log in",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  "Earn rewards, personalized outfits and more.",
                  style:
                      TextStyle(color: Colors.black54, fontSize: 14),
                ),

                const SizedBox(height: 25),

                // ---------- CARD ----------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color:
                              Colors.pinkAccent.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 12))
                    ],
                  ),
                  child: Column(
                    children: [
                      // AVATAR
                      Center(
                        child: GestureDetector(
                          onTap: _imageSheet,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.pink.shade50,
                              border:
                                  Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.pink
                                        .withOpacity(0.25),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10))
                              ],
                            ),
                            child: ClipOval(
                              child: _image == null
                                  ? Icon(Icons.camera_alt,
                                      size: 40,
                                      color: Colors.pink.shade300)
                                  : Image.file(_image!,
                                      fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // FIRST + LAST NAME
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                  controller: _firstCtrl,
                                  decoration:
                                      _dec("First name"))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: TextField(
                                  controller: _lastCtrl,
                                  decoration:
                                      _dec("Last name"))),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // EMAIL
                      TextField(
                          controller: _emailCtrl,
                          keyboardType:
                              TextInputType.emailAddress,
                          decoration: _dec("Email address")),

                      const SizedBox(height: 12),

                      // PHONE
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => showCountryPicker(
                              context: context,
                              onSelect: (c) =>
                                  setState(() => _country = c),
                              showPhoneCode: true,
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.grey.shade300),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                      "+${_country.phoneCode}",
                                      style: const TextStyle(
                                          fontWeight:
                                              FontWeight.w700)),
                                  const Icon(Icons
                                      .keyboard_arrow_down)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              onChanged: (txt) => setState(() =>
                                  _phoneCtrl.text =
                                      _formatPhone(txt)),
                              decoration:
                                  _dec("Phone number"),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // DOB
                      GestureDetector(
                        onTap: _pickDOB,
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dobCtrl,
                            decoration: _dec("Date of birth"),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // PASSWORD
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextField(
                            controller: _passwordCtrl,
                            obscureText: !_showPass,
                            decoration: _dec("Password"),
                          ),
                          Positioned(
                            right: 10,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _showPass =
                                      !_showPass),
                              child: Icon(
                                _showPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Positioned(
                              right: 50,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _strengthDot,
                                ),
                              ))
                        ],
                      ),

                      const SizedBox(height: 12),

                      // CONFIRM PASSWORD
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextField(
                            controller: _confirmCtrl,
                            obscureText: !_showConfirmPass,
                            decoration:
                                _dec("Re-enter password"),
                          ),
                          Positioned(
                            right: 10,
                            child: GestureDetector(
                              onTap: () => setState(() =>
                                  _showConfirmPass =
                                      !_showConfirmPass),
                              child: Icon(
                                _showConfirmPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_confirmCtrl.text.isNotEmpty &&
                          _confirmCtrl.text !=
                              _passwordCtrl.text)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8),
                          child: Text(
                            "Passwords do not match",
                            style: TextStyle(
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.w600),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // GENDER SLIDER (G1)
                      _genderSlider(),

                      const SizedBox(height: 22),

                      // CREATE ACCOUNT BUTTON
                      GestureDetector(
                        onTap: _submit,
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF6FAF),
                                Color(0xFFB97BFF)
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.pinkAccent
                                      .withOpacity(0.35),
                                  blurRadius: 22,
                                  offset: Offset(0, 10))
                            ],
                          ),
                          child: Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor:
                                Colors.white70,
                            child: const Center(
                              child: Text(
                                "CREATE ACCOUNT",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w900,
                                    letterSpacing: 1),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
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
