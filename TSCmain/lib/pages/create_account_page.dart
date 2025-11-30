// create_account_page.dart
// Playful / Pinteresty Create Account screen (Style C)
// Requires pubspec.yaml entries:
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

class _CreateAccountPageState extends State<CreateAccountPage>
    with TickerProviderStateMixin {
  // Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _firstCtrl = TextEditingController();
  final TextEditingController _lastCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();

  // Image
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  // Country
  late Country _country;

  // Gender segmented slider (playful)
  final List<String> _genders = ['Male', 'Female', 'Other'];
  int _genderIndex = 0;

  // Password helpers
  bool _showPassword = false;
  bool _showConfirm = false;
  Color _strengthDot = Colors.red;

  // UI animations
  late AnimationController _orbController;
  late AnimationController _cardIntroController;

  // Tilt subtle
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  // For phone formatting cursor handling
  bool _isFormattingPhone = false;

  @override
  void initState() {
    super.initState();
    _country = Country.parse('IN');

    _passwordCtrl.addListener(_evaluatePasswordStrength);
    _phoneCtrl.addListener(_onPhoneChanged);

    // playful orbs animation (repeat)
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _cardIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _cardIntroController.dispose();
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

  // -------------------- IMAGE PICKER --------------------
  Future<void> _pickImage(ImageSource src) async {
    try {
      final picked = await _picker.pickImage(source: src, imageQuality: 85, maxWidth: 1200);
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image error: $e')));
    }
  }

  void _openImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_imageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete_forever_outlined),
                  title: const Text('Remove photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _imageFile = null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // -------------------- DOB --------------------
  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 22),
      firstDate: DateTime(now.year - 90),
      lastDate: DateTime(now.year - 12),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: const Color(0xFFFF6FAF)),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      _dobCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  // -------------------- COUNTRY PICKER --------------------
  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (c) {
        setState(() {
          _country = c;
          // If phone empty, prefill code
          if (_phoneCtrl.text.trim().isEmpty) {
            _phoneCtrl.text = "+${c.phoneCode} ";
          } else if (!_phoneCtrl.text.startsWith('+')) {
            _phoneCtrl.text = "+${c.phoneCode} ${_phoneCtrl.text}";
          }
        });
      },
    );
  }

  // -------------------- PASSWORD STRENGTH --------------------
  void _evaluatePasswordStrength() {
    final s = _passwordCtrl.text;
    final len = s.length;
    if (len < 6) {
      _strengthDot = Colors.red;
    } else if (len < 10) {
      _strengthDot = Colors.amber;
    } else {
      _strengthDot = Colors.green;
    }
    setState(() {});
  }

  // -------------------- PHONE FORMAT (simple) --------------------
  void _onPhoneChanged() {
    if (_isFormattingPhone) return;
    _isFormattingPhone = true;
    final raw = _phoneCtrl.text;
    // Keep leading plus and country code if present
    final hasPlus = raw.startsWith('+');
    String numbers = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    // remove extra plus inside string except first
    if (hasPlus) {
      numbers = '+' + numbers.replaceAll('+', '');
    }

    // Remove non-digit (except leading +)
    final cleaned = hasPlus ? numbers.substring(1).replaceAll(RegExp(r'\D'), '') : numbers.replaceAll(RegExp(r'\D'), '');

    String formatted = cleaned;
    if (cleaned.length <= 3) {
      formatted = cleaned;
    } else if (cleaned.length <= 6) {
      formatted = "${cleaned.substring(0, 3)} ${cleaned.substring(3)}";
    } else if (cleaned.length <= 10) {
      formatted = "${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}";
    } else {
      // if longer, just chunk first 10 then append rest
      formatted = "${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 10)} ${cleaned.substring(10)}";
    }

    final result = hasPlus ? "+$formatted" : formatted;

    // set text while keeping cursor at end
    _phoneCtrl.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );

    _isFormattingPhone = false;
  }

  // -------------------- SUBMIT + scroll to error --------------------
  Future<void> _scrollTo(Widget? target, {double offset = 0}) async {
    // simple: scroll to top or small offset
    await _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _submit() {
    // Validate in order and scroll to top if error
    if (_firstCtrl.text.trim().isEmpty) {
      _scrollTo(null, offset: 0);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter first name')));
      return;
    }
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      _scrollTo(null, offset: 80);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      _scrollTo(null, offset: 260);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password is too weak')));
      return;
    }
    if (_confirmCtrl.text != _passwordCtrl.text) {
      _scrollTo(null, offset: 320);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    // Success (demo)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created — demo')));
  }

  // -------------------- UI PIECES --------------------
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: CurvedAnimation(parent: _cardIntroController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
          child: const Text(
            'Create your account',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFEE6FAF)),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Already registered? Log in',
            style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Join to get rewards, personalised picks & exclusive offers.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildAvatarRow() {
    return Row(
      children: [
        // Avatar circle with preview
        GestureDetector(
          onTap: _openImageOptions,
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _imageFile == null
                    ? LinearGradient(colors: [Colors.pink.shade50, Colors.purple.shade50])
                    : null,
                boxShadow: [
                  BoxShadow(color: Colors.pink.shade100.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 12)),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: ClipOval(
                child: _imageFile == null
                    ? Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Icon(Icons.camera_alt_outlined, size: 36, color: Colors.pink.shade300),
                        ),
                      )
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile photo', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Tap to upload or take a photo', style: TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _openImageOptions,
                    icon: const Icon(Icons.upload_file_outlined, size: 18),
                    label: const Text('Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.pink.shade400,
                      elevation: 0,
                      side: BorderSide(color: Colors.pink.shade50),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => setState(() => _imageFile = null),
                    child: const Text('Remove'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.pink.shade300),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    void Function()? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _genderSelector() {
    // playful segmented with pill background
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            alignment: () {
              switch (_genderIndex) {
                case 0:
                  return Alignment.centerLeft;
                case 1:
                  return Alignment.center;
                default:
                  return Alignment.centerRight;
              }
            }(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: (MediaQuery.of(context).size.width - 64) / 3, // approx
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF8AC5), Color(0xFFB97BFF)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.pink.shade100.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))],
              ),
            ),
          ),
          Row(
            children: List.generate(3, (i) {
              final label = _genders[i];
              final selected = i == _genderIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _genderIndex = i),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : Colors.black87,
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

  // Playful orbs in background
  Widget _orbs() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _orbController,
        builder: (context, _) {
          final t = _orbController.value;
          return Stack(
            children: [
              Positioned(
                left: 24 + sin(t * 2 * pi) * 18,
                top: 36 + cos(t * 2 * pi) * 10,
                child: _orbDot(120, Colors.pink.shade50),
              ),
              Positioned(
                right: 12 + cos(t * 1.4 * 2 * pi) * 22,
                top: 80 + sin(t * 2.1 * 2 * pi) * 12,
                child: _orbDot(90, Colors.purple.shade50),
              ),
              Positioned(
                left: 40 + sin(t * 1.8 * 2 * pi) * 12,
                bottom: 120 + cos(t * 1.6 * 2 * pi) * 18,
                child: _orbDot(140, Colors.pink.shade50.withOpacity(0.12)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _orbDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: [color, color.withOpacity(0.0)]),
        shape: BoxShape.circle,
      ),
    );
  }

  // -------------------- BUILD --------------------
  @override
  Widget build(BuildContext context) {
    final cardPad = 20.0;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      body: Listener(
        onPointerMove: (e) {
          final s = MediaQuery.of(context).size;
          final center = Offset(s.width / 2, s.height / 2);
          setState(() {
            _tiltY = ((e.position.dx - center.dx) / center.dx) * 6;
            _tiltX = ((center.dy - e.position.dy) / center.dy) * 6;
          });
        },
        onPointerUp: (_) {
          setState(() {
            _tiltX = 0;
            _tiltY = 0;
          });
        },
        child: Stack(
          children: [
            // Orbs background
            Positioned.fill(child: _orbs()),

            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
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
                      _buildHeader(),
                      const SizedBox(height: 12),

                      // Main card
                      ScaleTransition(
                        scale: CurvedAnimation(parent: _cardIntroController, curve: Curves.easeOutBack),
                        child: Container(
                          padding: EdgeInsets.all(cardPad),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.pink.shade50.withOpacity(0.9), blurRadius: 30, offset: const Offset(0, 14)),
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildAvatarRow(),
                              const SizedBox(height: 18),

                              // name
                              Row(
                                children: [
                                  Expanded(child: _buildTextField(controller: _firstCtrl, hint: 'First name')),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField(controller: _lastCtrl, hint: 'Last name')),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // email
                              _buildTextField(controller: _emailCtrl, hint: 'Email address', keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 12),

                              // country + phone
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
                                          const Icon(Icons.keyboard_arrow_down),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField(controller: _phoneCtrl, hint: 'Phone number', keyboardType: TextInputType.phone)),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // dob + password row
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _pickDOB,
                                      child: AbsorbPointer(
                                        child: _buildTextField(controller: _dobCtrl, hint: 'Date of birth (YYYY-MM-DD)'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        _buildTextField(controller: _passwordCtrl, hint: 'Password', obscure: !_showPassword),
                                        Positioned(
                                          right: 40,
                                          child: IconButton(
                                            onPressed: () => setState(() => _showPassword = !_showPassword),
                                            icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                                            color: Colors.black45,
                                          ),
                                        ),
                                        Positioned(
                                          right: 12,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: _strengthDot),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // confirm password
                              Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  _buildTextField(controller: _confirmCtrl, hint: 'Re-enter password', obscure: !_showConfirm),
                                  Positioned(
                                    right: 12,
                                    child: IconButton(
                                      onPressed: () => setState(() => _showConfirm = !_showConfirm),
                                      icon: Icon(_showConfirm ? Icons.visibility : Icons.visibility_off),
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),

                              if (_confirmCtrl.text.isNotEmpty && _confirmCtrl.text != _passwordCtrl.text)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('Passwords do not match', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
                                ),

                              const SizedBox(height: 18),

                              // playful gender selector
                              _genderSelector(),

                              const SizedBox(height: 18),

                              // terms / checkbox simplified
                              Row(
                                children: [
                                  Checkbox(value: true, onChanged: (_) {}),
                                  Expanded(child: Text('I agree to Terms & Privacy', style: TextStyle(color: Colors.black54))),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // CTA
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Ink(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
                                      borderRadius: BorderRadius.all(Radius.circular(14)),
                                    ),
                                    child: Center(
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.white,
                                        highlightColor: Colors.white70,
                                        child: const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),
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
}
