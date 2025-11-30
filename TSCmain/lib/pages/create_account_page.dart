// pubspec.yaml (add these)
// image_picker: ^1.0.7
// country_picker: ^2.0.21
// shimmer: ^3.0.0

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:shimmer/shimmer.dart';

/// CreateAccountPage
/// - Pinterest-y, pink & white aesthetic
/// - Profile picture upload (camera / gallery)
/// - DOB picker
/// - Country picker (no external flag package required)
/// - Gender segmented slider (slidable)
/// - Password strength dot (red / orange / green)
/// - Re-enter password validation
/// - Auto phone formatting
/// - Show password toggle
/// - Smooth scroll-to-error (uses GlobalKeys)
/// - Subtle tilt + micro-animations + shimmer on primary CTA
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage>
    with TickerProviderStateMixin {
  // Text controllers
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _dob = TextEditingController();

  final _scroll = ScrollController();

  // GlobalKeys for error scrolling
  final _firstKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();
  final _confirmKey = GlobalKey();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _image;

  // Country & gender
  Country _country = Country.parse("IN");
  final List<String> _genders = ["Male", "Female", "Other"];
  int _genderIndex = 0;

  // UI toggles & visuals
  bool _showPass = false;
  bool _showConfirm = false;
  Color _strengthDot = Colors.red;
  double _tiltX = 0;
  double _tiltY = 0;

  // small animation controllers
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _country = Country.parse("IN");
    _password.addListener(_updateStrength);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.95,
      upperBound: 1.02,
    )..repeat(reverse: true);

    // prefill sample phone prefix (optional)
    _phone.text = "+${_country.phoneCode} ";
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    _dob.dispose();
    _scroll.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ---------------- Image handling ----------------
  Future<void> _pickImage(ImageSource src) async {
    try {
      final picked = await _picker.pickImage(
        source: src,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 86,
      );
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {
      // ignore for now
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take photo"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from gallery"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_image != null)
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text("Remove photo"),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _image = null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- Password strength ----------------
  void _updateStrength() {
    final p = _password.text;
    Color next;
    if (p.length < 6) next = Colors.red;
    else if (p.length < 10) next = Colors.orange;
    else next = Colors.green;
    setState(() => _strengthDot = next);
  }

  // ---------------- DOB picker ----------------
  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 22),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 12),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFF6FAF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      _dob.text =
          "${picked.year}-${picked.month.toString().padLeft(2, "0")}-${picked.day.toString().padLeft(2, "0")}";
      setState(() {});
    }
  }

  // ---------------- Country picker ----------------
  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (c) {
        setState(() {
          _country = c;
          if (!_phone.text.startsWith("+")) _phone.text = "+${c.phoneCode} ";
        });
      },
    );
  }

  // ---------------- Phone formatting ----------------
  String _formatPhone(String input) {
    final numbers = input.replaceAll(RegExp(r'\D'), '');
    if (numbers.isEmpty) return "";
    if (numbers.length <= 3) return numbers;
    if (numbers.length <= 6) return "${numbers.substring(0, 3)} ${numbers.substring(3)}";
    if (numbers.length <= 10) {
      return "${numbers.substring(0, 3)} ${numbers.substring(3, 6)} ${numbers.substring(6)}";
    }
    return numbers;
  }

  // ---------------- Scroll to error ----------------
  Future<void> _scrollToKey(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) {
      await _scroll.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      return;
    }
    final box = ctx.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
    final offset = _scroll.offset + pos.dy - 120;
    await _scroll.animateTo(offset.clamp(0.0, _scroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 420), curve: Curves.easeInOut);
  }

  // ---------------- Submit ----------------
  void _submit() {
    // Basic validation order: first -> email -> password -> confirm
    if (_first.text.trim().isEmpty) {
      _scrollToKey(_firstKey);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your first name")));
      return;
    }
    if (_email.text.trim().isEmpty || !_email.text.contains("@")) {
      _scrollToKey(_emailKey);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid email")));
      return;
    }
    if (_password.text.length < 6) {
      _scrollToKey(_passwordKey);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password is too weak")));
      return;
    }
    if (_confirm.text != _password.text) {
      _scrollToKey(_confirmKey);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    // Success - demo
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account created (demo)")));
    // proceed to next screen in real app
  }

  // ---------------- Tilt pointer handling ----------------
  void _onPointerMove(PointerEvent e) {
    final size = MediaQuery.of(context).size;
    final c = Offset(size.width / 2, size.height / 2);
    final dx = (e.position.dx - c.dx) / c.dx;
    final dy = (e.position.dy - c.dy) / c.dy;
    setState(() {
      _tiltY = (dx * 7).clamp(-7.0, 7.0);
      _tiltX = (-dy * 7).clamp(-7.0, 7.0);
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  // ---------------- Build helpers - styled components ----------------
  InputDecoration _inputDecor(String hint, {Widget? prefix}) {
    return InputDecoration(
      prefixIcon: prefix,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87));

  // Profile avatar widget
  Widget _profileAvatar() {
    const double size = 100;
    return GestureDetector(
      onTap: _showImageOptions,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: !_hasImage ? const LinearGradient(colors: [Color(0xFFFFF2F6), Color(0xFFFFF8FB)]) : null,
            boxShadow: [
              BoxShadow(color: Colors.pink.shade100.withOpacity(0.45), blurRadius: 22, offset: const Offset(0, 10)),
            ],
            border: Border.all(color: Colors.white, width: 4),
            image: _hasImage
                ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                : null,
          ),
          child: !_hasImage
              ? Center(
                  child: Icon(Icons.camera_alt_outlined, color: Colors.pink.shade400, size: 34),
                )
              : null,
        ),
      ),
    );
  }

  bool get _hasImage => _image != null;

  Widget _genderSegment() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOutCubic,
            alignment: [
              Alignment.centerLeft,
              Alignment.center,
              Alignment.centerRight
            ][_genderIndex],
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              width: (MediaQuery.of(context).size.width - 84) / 3, // approx width per segment
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF8DC1), Color(0xFFBD86FF)]),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.pink.shade100.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
              ),
            ),
          ),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _genderIndex = i),
                  child: Container(
                    height: 46,
                    alignment: Alignment.center,
                    child: Text(
                      _genders[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _genderIndex == i ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Primary CTA with shimmer and pulsating micro-scale
  Widget _primaryCTA() {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)),
      child: GestureDetector(
        onTap: _submit,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
            boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.26), blurRadius: 28, offset: const Offset(0, 10))],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.white70,
            child: const Center(
              child: Text("CREATE ACCOUNT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.6)),
            ),
          ),
        ),
      ),
    );
  }

  // top pink header decorative line
  Widget _pinkAccentLine() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 56,
        height: 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: const LinearGradient(colors: [Color(0xFFFF9EC4), Color(0xFFBD86FF)]),
        ),
      ),
    );
  }

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _resetTilt(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF7F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("", style: TextStyle(color: Colors.black87)),
        ),
        body: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_tiltX * pi / 180)
              ..rotateY(_tiltY * pi / 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pinkAccentLine(),
                const SizedBox(height: 14),
                const Text(
                  "Create your account",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFFDB2B77)),
                ),
                const SizedBox(height: 8),
                const Text("Join to get rewards, curated picks and early offers.", style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 18),

                // "Already registered?" placed under title, clean
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text("Already registered? Log in", style: TextStyle(color: Colors.pink.shade600, fontWeight: FontWeight.w700)),
                ),

                const SizedBox(height: 20),

                // Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.pink.shade50.withOpacity(0.9), blurRadius: 30, offset: const Offset(0, 12))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // avatar
                          _profileAvatar(),
                          const SizedBox(width: 16),

                          // basic info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Profile photo"),
                                const SizedBox(height: 6),
                                const Text("Tap to upload • PNG, JPG • < 5MB", style: TextStyle(color: Colors.black54, fontSize: 12)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _showImageOptions,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        elevation: 0,
                                        foregroundColor: Colors.pink.shade400,
                                        side: BorderSide(color: Colors.pink.shade50),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: Icon(Icons.upload_file, color: Colors.pink.shade400),
                                      label: const Text("Upload", style: TextStyle(color: Colors.black87)),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () => setState(() => _image = null),
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.pink.shade400),
                                      child: const Text("Remove"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // name fields
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              key: _firstKey,
                              child: TextField(controller: _first, decoration: _inputDecor("First name")),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: _last, decoration: _inputDecor("Last name"))),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // email
                      Container(
                        key: _emailKey,
                        child: TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecor("Email address"),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // phone & country
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _openCountryPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                              child: Row(
                                children: [
                                  Text("+${_country.phoneCode}", style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 8),
                                  // show country flag as emoji (no extra package)
                                  Text(_country.flagEmoji, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_drop_down, color: Colors.black54),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              onChanged: (s) {
                                final formatted = _formatPhone(s);
                                // attempt to keep caret at end (simple)
                                _phone.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(offset: formatted.length),
                                );
                              },
                              decoration: _inputDecor("Phone number"),
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
                            controller: _dob,
                            decoration: _inputDecor("Date of birth (YYYY-MM-DD)"),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // password + strength dot
                      Container(
                        key: _passwordKey,
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            TextField(
                              controller: _password,
                              obscureText: !_showPass,
                              decoration: _inputDecor("Password"),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // strength dot
                                Container(width: 12, height: 12, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(shape: BoxShape.circle, color: _strengthDot)),
                                GestureDetector(
                                  onTap: () => setState(() => _showPass = !_showPass),
                                  child: Icon(_showPass ? Icons.visibility : Icons.visibility_off, color: Colors.black45),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // confirm password
                      Container(
                        key: _confirmKey,
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            TextField(controller: _confirm, obscureText: !_showConfirm, decoration: _inputDecor("Re-enter password")),
                            GestureDetector(
                              onTap: () => setState(() => _showConfirm = !_showConfirm),
                              child: Icon(_showConfirm ? Icons.visibility : Icons.visibility_off, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),

                      // password match notice
                      if (_confirm.text.isNotEmpty && _confirm.text != _password.text)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, size: 16, color: Colors.redAccent),
                              const SizedBox(width: 8),
                              Text("Passwords don't match", style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // gender selector (slidable segmented)
                      _label("Gender"),
                      const SizedBox(height: 8),
                      _genderSegment(),

                      const SizedBox(height: 18),

                      // terms row
                      Row(
                        children: [
                          Checkbox(value: true, onChanged: (_) {}),
                          Expanded(child: Text("I agree to the Terms & Privacy policy", style: TextStyle(color: Colors.black54))),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // CTA
                      _primaryCTA(),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // subtle footer
                Center(
                  child: Text("By creating an account you agree to our Terms & Conditions", style: TextStyle(color: Colors.black54, fontSize: 12)),
                ),

                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
──────────────────────────────────────────────────────
Notes:
- Add the packages listed at top to pubspec.yaml
- country_picker includes Country.flagEmoji which we use to display a flag without needing country_icons.
- This page is designed to be Pinterest-y (pink + white), interactive and animated.
──────────────────────────────────────────────────────
*/
