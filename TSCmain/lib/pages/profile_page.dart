// lib/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/login_page.dart';
import 'package:sirelle/l10n/app_localizations.dart';
import 'package:sirelle/controllers/app_locale.dart';
import 'package:sirelle/controllers/app_theme.dart';
// import other packages as needed for your app routing/state management

// ────────────── FULL-PAGE ADDRESS FORM ──────────────
// Add/Edit Address (Nykaa / Amazon style)
class AddressFormPage extends StatefulWidget {
  final String? initialAddress;
  final String title;

  const AddressFormPage({
    super.key,
    required this.title,
    this.initialAddress,
  });

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _flatController = TextEditingController();
  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String addressType = 'Home';
  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _flatController.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _flatController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Add New Address',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _flatController,
                    decoration: _input('Flat No / Building / Company*'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _streetController,
                    decoration: _input('Street Name, Area*'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _landmarkController,
                    decoration: _input('Landmark'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    decoration: _input('Pincode*'),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          decoration: _input('City/District'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _stateController,
                          decoration: _input('State'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Save Address As',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: ['Home', 'Work', 'Other'].map((type) {
                      final selected = addressType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: selected,
                          selectedColor: Colors.red.shade50,
                          labelStyle: TextStyle(
                            color: selected ? Colors.red : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) {
                            setState(() => addressType = type);
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isDefault,
                    onChanged: (v) => setState(() => isDefault = v ?? false),
                    title: const Text(
                      'Save This As Default Address',
                      style: TextStyle(fontSize: 14),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ),

          // SAVE BUTTON (sticky bottom)
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_flatController.text.trim().isEmpty ||
                      _streetController.text.trim().isEmpty ||
                      _pincodeController.text.trim().isEmpty) return;

                  final fullAddress = [
                    _flatController.text,
                    _streetController.text,
                    _landmarkController.text,
                    _cityController.text,
                    _stateController.text,
                    _pincodeController.text,
                  ].where((e) => e.isNotEmpty).join(', ');

                  Navigator.pop(context, fullAddress);
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final bool openCoupons;

  const ProfilePage({
    super.key,
    this.openCoupons = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// ================= RETRO PROFILE CARD =================

class RetroProfileCard extends StatelessWidget {
  final String name;
  final String birth;
  final String height;
  final String blood;
  final Color backgroundColor;
  final File? avatarFile;
  final void Function(String field)? onEdit;

  const RetroProfileCard({
    super.key,
    required this.name,
    required this.birth,
    required this.height,
    required this.blood,
    required this.backgroundColor,
    this.avatarFile,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    _RetroDot(color: Colors.red),
                    SizedBox(width: 4),
                    _RetroDot(color: Colors.yellow),
                    SizedBox(width: 4),
                    _RetroDot(color: Colors.green),
                    Spacer(),
                    Text(
                      "PROFILE://USER",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: Colors.black),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with checkerboard background
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 130,
                          width: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: _CheckerboardBG(
                              squareSize: 12,
                              color1: Colors.white,
                              color2: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        Container(
                          height: 130,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: avatarFile != null
                              ? ClipRect(
                                  child: Image.file(
                                    avatarFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.person, size: 46),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _retroRow("NAME", name, onTap: () => onEdit?.call("NAME")),
                          _retroRow("BIRTH", birth, onTap: () => onEdit?.call("BIRTH")),
                          _retroRow("HEIGHT", height, onTap: () => onEdit?.call("HEIGHT")),
                          _retroRow("BLOOD", blood, onTap: () => onEdit?.call("BLOOD")),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Hearts row
                const _HeartsRow(),
                const SizedBox(height: 14),
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    alignment: Alignment.centerLeft,
                    child: Container(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ScanlinePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modified _retroRow to accept onTap
  Widget _retroRow(String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(letterSpacing: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Checkerboard background widget for retro avatar
class _CheckerboardBG extends StatelessWidget {
  final double squareSize;
  final Color color1;
  final Color color2;
  const _CheckerboardBG({
    this.squareSize = 10,
    this.color1 = Colors.white,
    this.color2 = const Color(0xFFE0E0E0),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(
        squareSize: squareSize,
        color1: color1,
        color2: color2,
      ),
      child: Container(),
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  final double squareSize;
  final Color color1;
  final Color color2;
  _CheckerboardPainter({
    required this.squareSize,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int y = 0; y < size.height / squareSize; y++) {
      for (int x = 0; x < size.width / squareSize; x++) {
        paint.color = ((x + y) % 2 == 0) ? color1 : color2;
        canvas.drawRect(
          Rect.fromLTWH(
            x * squareSize,
            y * squareSize,
            squareSize,
            squareSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated retro hearts row widget
class _HeartsRow extends StatefulWidget {
  const _HeartsRow({Key? key}) : super(key: key);

  @override
  State<_HeartsRow> createState() => _HeartsRowState();
}

class _HeartsRowState extends State<_HeartsRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5 hearts, center pulse
    return SizedBox(
      height: 26,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                double scale = 1.0;
                if (i == 2) {
                  // center heart pulses
                  scale = 1.0 + 0.24 * _controller.value;
                } else if (i == 1 || i == 3) {
                  scale = 1.0 + 0.08 * _controller.value;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.pink.shade600,
                      size: 17,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _RetroDot extends StatelessWidget {
  final Color color;
  const _RetroDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  void _openGiftCardsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final TextEditingController controller = TextEditingController();

        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Text(
                'Gift Cards',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),

              // Redeem section
              const Text(
                'Redeem Gift Card',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter gift card code',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (controller.text.isEmpty) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid or expired gift card'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    'REDEEM',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 26),
              const Divider(),

              // Buy section
              const SizedBox(height: 16),
              const Text(
                'Buy Gift Card',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.pink.shade600),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Send gift cards to friends & family.\nComing soon!',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCouponsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        String? appliedCoupon;
        final TextEditingController controller = TextEditingController();

        final coupons = [
          {
            'code': 'FLAT10',
            'desc': 'Flat ₹100 OFF',
            'cond': 'Min order ₹999',
            'expiry': 'Expires in 3 days',
          },
          {
            'code': 'WELCOME15',
            'desc': '15% OFF for new users',
            'cond': 'Max discount ₹300',
            'expiry': 'Expires in 7 days',
          },
          {
            'code': 'FREESHIP',
            'desc': 'Free Delivery',
            'cond': 'No minimum order',
            'expiry': 'Limited time',
          },
        ];

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Text(
                    'Coupons',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Enter coupon code',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            setSheetState(() {
                              appliedCoupon =
                                  controller.text.toUpperCase();
                            });
                          }
                        },
                        child: const Text('APPLY'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: ListView.builder(
                      itemCount: coupons.length,
                      itemBuilder: (_, i) {
                        final c = coupons[i];
                        final bool isApplied =
                            appliedCoupon == c['code'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isApplied
                                  ? Colors.green
                                  : Colors.black12,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c['code']!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(c['desc']!),
                                    const SizedBox(height: 4),
                                    Text(
                                      c['cond']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c['expiry']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: c['code']!),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${c['code']} copied'),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Text(
                                  'COPY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.pink.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // Replace with your real user state / provider
  String userName = 'Guest User';
  bool get isGuest =>
      FirebaseAuth.instance.currentUser == null;
  String membership = 'Non-Member';
  File? avatarFile;
  String birth = 'YYYYMMDD';
  String height = '—';
  String blood = '—';
  bool _pressed = false;
  String theme = 'pink';
  List<String> addresses = [];
  int defaultAddressIndex = -1;
  Color _themeBg() {
    switch (theme) {
      case 'beige':
        return const Color(0xFFF3E8D8);
      case 'mint':
        return const Color(0xFFDFF2EC);
      default:
        return const Color(0xFFE9C9DD);
    }
  }

  // theme helpers (matching drawer)
  Color get _accent => Colors.pink.shade600;
  Color get _muted => Colors.pink.shade50;
  Color get _textDark => Colors.pink.shade900;

  void onEditTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          initialUsername: userName,
          initialAvatar: avatarFile,
        ),
      ),
    );
    if (result is Map<String, dynamic>) {
      setState(() {
        if (result['username'] != null) userName = result['username'];
        if (result['avatarFile'] != null)
          avatarFile = result['avatarFile'] as File;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _listenAuth();

    if (widget.openCoupons) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openCouponsSheet();
      });
    }
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // userName comes from FirebaseAuth, not prefs
      birth = prefs.getString('birth') ?? birth;
      height = prefs.getString('height') ?? height;
      blood = prefs.getString('blood') ?? blood;
      addresses = prefs.getStringList('addresses') ?? [];
      defaultAddressIndex = prefs.getInt('default_address_index') ?? -1;
    });
  }

  void _listenAuth() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      setState(() {
        if (user != null && user.displayName?.isNotEmpty == true) {
          userName = user.displayName!;
        } else {
          userName = 'Guest User';
        }
      });
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', userName);
    await prefs.setString('birth', birth);
    await prefs.setString('height', height);
    await prefs.setString('blood', blood);
    await prefs.setStringList('addresses', addresses);
    await prefs.setInt('default_address_index', defaultAddressIndex);
  }

  Future<void> _editField(String label, String current, Function(String) onSave) async {
    final controller = TextEditingController(text: current);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                onSave(controller.text);
              });
              _saveProfile();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ────────────── ADDRESS MANAGEMENT ──────────────
  void _openAddressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                18,
                12,
                18,
                MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // drag handle
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Saved Addresses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _addAddress(setSheetState),
                        child: const Text(
                          '+ ADD NEW',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (addresses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(Icons.location_on_outlined,
                                size: 48, color: Colors.black26),
                            SizedBox(height: 12),
                            Text(
                              'No saved addresses',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add an address to get faster delivery',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ...List.generate(addresses.length, (i) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            defaultAddressIndex == i
                                ? Icons.check_circle
                                : Icons.location_on_outlined,
                            size: 22,
                            color: defaultAddressIndex == i
                                ? Colors.green
                                : Colors.black54,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (defaultAddressIndex == i)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'DEFAULT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                Text(
                                  addresses[i],
                                  style: const TextStyle(height: 1.4),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () {
                                    setSheetState(() {
                                      defaultAddressIndex = i;
                                      _saveProfile();
                                    });
                                  },
                                  child: Text(
                                    defaultAddressIndex == i
                                        ? 'Default address'
                                        : 'Make this default',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: defaultAddressIndex == i
                                          ? Colors.green
                                          : Colors.pink.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editAddress(i, setSheetState);
                              } else if (value == 'delete') {
                                setSheetState(() {
                                  if (defaultAddressIndex == i) {
                                    defaultAddressIndex = -1;
                                  } else if (defaultAddressIndex > i) {
                                    defaultAddressIndex--;
                                  }
                                  addresses.removeAt(i);
                                  _saveProfile();
                                });
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addAddress(Function setSheetState) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressFormPage(title: 'Add Address'),
      ),
    );

    if (result is String) {
      setSheetState(() {
        addresses.add(result);
        if (defaultAddressIndex == -1) {
          defaultAddressIndex = addresses.length - 1;
        }
        _saveProfile();
      });
    }
  }

  void _editAddress(int index, Function setSheetState) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressFormPage(
          title: 'Edit Address',
          initialAddress: addresses[index],
        ),
      ),
    );

    if (result is String) {
      setSheetState(() {
        addresses[index] = result;
        _saveProfile();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCEEEE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _textDark,
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Column(
                  children: [
                    GestureDetector(
                      onTapDown: (_) => setState(() => _pressed = true),
                      onTapUp: (_) => setState(() => _pressed = false),
                      onTapCancel: () => setState(() => _pressed = false),
                      child: AnimatedScale(
                        scale: _pressed ? 0.97 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        child: RetroProfileCard(
                          name: userName,
                          birth: birth,
                          height: height,
                          blood: blood,
                          backgroundColor: _themeBg(),
                          avatarFile: avatarFile,
                          onEdit: (field) {
                            if (field == 'NAME') {
                              _editField('Name', userName, (v) => userName = v);
                            } else if (field == 'BIRTH') {
                              _editField('Birth', birth, (v) => birth = v);
                            } else if (field == 'HEIGHT') {
                              _editField('Height', height, (v) => height = v);
                            } else if (field == 'BLOOD') {
                              _editField('Blood', blood, (v) => blood = v);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ======= Orders (dropdown, UI unchanged) =======
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            title: Text(
                              AppLocalizations.of(context)!.orders,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                            ),
                            iconColor: _accent,
                            collapsedIconColor: Colors.black26,
                            childrenPadding: const EdgeInsets.only(bottom: 12),
                            children: [
                              // --- ORIGINAL ORDERS UI (UNCHANGED) ---
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0,
                                  vertical: 6,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        leading: Container(
                                          height: 44,
                                          width: 44,
                                          decoration: BoxDecoration(
                                            color: _muted,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(Icons.list_alt, color: _accent),
                                        ),
                                        title: Text(
                                          'My Orders',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _textDark,
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.black26,
                                        ),
                                        onTap: () {
                                          /* open full orders page */
                                        },
                                      ),
                                      const Divider(height: 1),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10.0,
                                          horizontal: 12,
                                        ),
                                        child: SizedBox(
                                          width: 300,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            physics: BouncingScrollPhysics(),
                                            child: Row(
                                              children: [
                                                _orderStatus('Processing', Icons.hourglass_bottom),
                                                const SizedBox(width: 14),
                                                _orderStatus('Shipped', Icons.local_shipping),
                                                const SizedBox(width: 14),
                                                _orderStatus('Delivered', Icons.check_circle_outline),
                                                const SizedBox(width: 14),
                                                _orderStatus('Cancelled', Icons.cancel_outlined),
                                                const SizedBox(width: 14),
                                                _orderStatus('Returned', Icons.undo),
                                                const SizedBox(width: 14),
                                                _orderStatus('Unpaid', Icons.payments_outlined),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      /* open tracking page */
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      curve: Curves.easeOut,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.map_outlined,
                                            size: 18,
                                            color: Colors.pink.shade700,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Track Order',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.pink.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ======= Addresses (no icon, after Orders) =======
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            splashColor: Colors.pink.withOpacity(0.08),
                            highlightColor: Colors.pink.withOpacity(0.04),
                            onTap: () {
                              _openAddressSheet();
                            },
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              visualDensity: VisualDensity.standard,
                              title: Text(
                                AppLocalizations.of(context)!.addresses,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.pink.shade900,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.black26),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ======= Offers & Wallet =======
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            title: Text(
                              'Offers & Wallet',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                            ),
                            iconColor: _accent,
                            collapsedIconColor: Colors.black26,
                            childrenPadding: const EdgeInsets.only(bottom: 12),
                            children: [
                              profileOptionTile(
                                context,
                                Icons.local_offer_outlined,
                                'Coupons',
                                onTap: () {
                                  _openCouponsSheet();
                                },
                              ),
                              profileOptionTile(
                                context,
                                Icons.card_giftcard,
                                'Gift Cards',
                                onTap: () {
                                  _openGiftCardsSheet();
                                },
                              ),
                              profileOptionTile(
                                context,
                                Icons.account_balance_wallet,
                                'App Wallet Balance',
                                onTap: () {
                                  /* wallet balance */
                                },
                              ),
                              profileOptionTile(
                                context,
                                Icons.loyalty_outlined,
                                'Rewards / Loyalty Points',
                                onTap: () {
                                  /* rewards */
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),



                    // ======= App Settings (expansion) =======
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  'Preferences',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _textDark,
                                  ),
                                ),
                                iconColor: _accent,
                                collapsedIconColor: Colors.black26,
                                childrenPadding: const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                children: [
                                  profileOptionTile(
                                    context,
                                    Icons.language,
                                    AppLocalizations.of(context)!.language,
                                    subtitle: languageNameFromLocale(AppLocale.locale.value),
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) => ListView(
                                          children: [
                                            ListTile(
                                              title: const Text('English'),
                                              onTap: () {
                                                AppLocale.set(const Locale('en'));
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('Hindi'),
                                              onTap: () {
                                                AppLocale.set(const Locale('hi'));
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('Kannada'),
                                              onTap: () {
                                                AppLocale.set(const Locale('kn'));
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.color_lens_outlined,
                                    AppLocalizations.of(context)!.theme,
                                    subtitle: AppTheme.themeMode.value == ThemeMode.dark ? 'Dark' : 'Light',
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) => Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              title: const Text('Light Mode'),
                                              trailing: AppTheme.themeMode.value == ThemeMode.light
                                                  ? const Icon(Icons.check)
                                                  : null,
                                              onTap: () {
                                                AppTheme.setDark(false);
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('Dark Mode'),
                                              trailing: AppTheme.themeMode.value == ThemeMode.dark
                                                  ? const Icon(Icons.check)
                                                  : null,
                                              onTap: () {
                                                AppTheme.setDark(true);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.public,
                                    'Country / Region',
                                    subtitle: 'India',
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) => ListView(
                                          children: [
                                            ListTile(title: Text('India'), onTap: () => Navigator.pop(context)),
                                            ListTile(title: Text('United States'), onTap: () => Navigator.pop(context)),
                                            ListTile(title: Text('United Kingdom'), onTap: () => Navigator.pop(context)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.notifications_none,
                                    AppLocalizations.of(context)!.notifications,
                                    subtitle: 'On',
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) => SwitchListTile(
                                          title: Text('Enable Notifications'),
                                          value: true,
                                          onChanged: (_) {},
                                        ),
                                      );
                                    },
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.lock_outline,
                                    'Privacy Controls',
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======= Help & Information (dropdown) =======
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  'Help & Info',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromARGB(
                                      255,
                                      136,
                                      14,
                                      79,
                                    ),
                                  ),
                                ),
                                children: [
                                  profileOptionTile(
                                    context,
                                    Icons.help_outline,
                                    'Help Center',
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.report_problem_outlined,
                                    'Report an issue',
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.chat_bubble_outline,
                                    'Chat with Support',
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.description_outlined,
                                    'Terms & Conditions',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======= Privacy Policies (expansion tile version) =======
                    ProfileSection(
                      title: '',
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 6,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              title: Text(
                                'Privacy & Policies',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.pink.shade900,
                                ),
                              ),
                              iconColor: Colors.pink.shade600,
                              collapsedIconColor: Colors.black26,
                              childrenPadding: const EdgeInsets.only(
                                bottom: 12,
                              ),
                              children: [
                                profileOptionTile(
                                  context,
                                  Icons.privacy_tip,
                                  'Privacy Policy',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.article_outlined,
                                  'Terms & Conditions',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.assignment_return,
                                  'Return & Refund Policy',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.local_shipping_outlined,
                                  'Shipping / Delivery Policy',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.cancel_outlined,
                                  'Cancellation Policy',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.payment,
                                  'Payment Policy',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.cookie_outlined,
                                  'Cookie Policy',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.person_outline,
                                  'User Account Policy',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.copyright,
                                  'Content & Copyright Policy',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.security_outlined,
                                  'Safety & Security Policy',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.support_agent,
                                  'Support & Complaint Policy',
                                ),
                                profileOptionTile(
                                  context,
                                  Icons.store_mall_directory_outlined,
                                  'Seller Policy',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ======= About the App =======
                    ProfileSection(
                      title: 'About',
                      children: [
                        profileOptionTile(
                          context,
                          Icons.info_outline,
                          'About Us',
                        ),
                        profileOptionTile(
                          context,
                          Icons.privacy_tip_outlined,
                          'App Version',
                          subtitle: '1.0.0',
                        ),
                      ],
                    ),

                    // ======= Logout/Login button (scrollable element) =======
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 12,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: _accent, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (isGuest) {
                              // 👉 Guest → Login
                              if (!context.mounted) return;
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 250),
                                  pageBuilder: (_, __, ___) => const LoginPage(),
                                  transitionsBuilder: (_, animation, __, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            } else {
                              // 👉 Logged-in → Logout
                              await FirebaseAuth.instance.signOut();

                              final prefs = await SharedPreferences.getInstance();
                              await prefs.remove('last_active_time');

                              if (!context.mounted) return;
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 250),
                                  pageBuilder: (_, __, ___) => const LoginPage(),
                                  transitionsBuilder: (_, animation, __, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          child: Text(
                            isGuest
                                ? 'Login'
                                : AppLocalizations.of(context)!.logout,
                            style: TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // small reusable widgets used above

  Widget _orderStatus(String label, IconData icon) {
    return Column(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.pink.shade700, size: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// Reusable tile widget
Widget profileOptionTile(
  BuildContext context,
  IconData icon,
  String title, {
  String? subtitle,
  VoidCallback? onTap,
}) {
  final Color accent = Colors.pink.shade600;
  final Color muted = Colors.pink.shade50;
  final Color textDark = Colors.pink.shade900;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: ListTile(
        minVerticalPadding: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: muted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
        onTap: onTap,
      ),
    ),
  );
}

// Simple ProfileSection header + children
class ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const double gap = 12;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 18.0, bottom: gap),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ...children
              .expand((w) => [w, const SizedBox(height: gap)])
              .toList()
            ..removeLast(),
        ],
      ),
    );
  }
}

// ===== Edit Profile Page (change username + change photo) =====

String languageNameFromLocale(Locale locale) {
  switch (locale.languageCode) {
    case 'hi':
      return 'हिन्दी';
    case 'kn':
      return 'ಕನ್ನಡ';
    default:
      return 'English';
  }
}
class EditProfilePage extends StatefulWidget {
  final String? initialUsername;
  final File? initialAvatar;
  const EditProfilePage({super.key, this.initialUsername, this.initialAvatar});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  File? avatarFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.initialUsername ?? '';
    avatarFile = widget.initialAvatar;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => avatarFile = File(picked.path));
      }
    } catch (e) {
      // handle errors (permission, etc.)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Editable Profile Picture
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 52,
                backgroundColor: Colors.pink.shade200,
                backgroundImage: avatarFile != null
                    ? FileImage(avatarFile!)
                    : null,
                child: avatarFile == null
                    ? const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 36,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            // Username Field (ONLY username allowed)
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Return updated data to previous page (replace with your save API)
                  Navigator.pop(context, {
                    'username': usernameController.text,
                    'avatarFile': avatarFile,
                  });
                },
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
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

// CRT scanline painter
class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.05);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



