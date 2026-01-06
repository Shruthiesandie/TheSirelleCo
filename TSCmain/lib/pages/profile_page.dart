// lib/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// add to pubspec
// import other packages as needed for your app routing/state management

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
  // Replace with your real user state / provider
  String userName = 'Guest User';
  String membership = 'Non-Member';
  File? avatarFile;
  String birth = 'YYYYMMDD';
  String height = '—';
  String blood = '—';
  bool _pressed = false;
  String theme = 'pink';
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
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? userName;
      birth = prefs.getString('birth') ?? birth;
      height = prefs.getString('height') ?? height;
      blood = prefs.getString('blood') ?? blood;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', userName);
    await prefs.setString('birth', birth);
    await prefs.setString('height', height);
    await prefs.setString('blood', blood);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCEEEE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _textDark,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
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

                    // ======= My Account =======
                    ProfileSection(
                      title: 'My Account',
                      children: [
                        profileOptionTile(
                          context,
                          Icons.person_outline,
                          'Profile',
                          onTap: () {
                            /* open profile details */
                          },
                        ),
                        profileOptionTile(
                          context,
                          Icons.location_on_outlined,
                          'Addresses',
                          onTap: () {
                            /* addresses */
                          },
                        ),
                        profileOptionTile(
                          context,
                          Icons.shopping_cart_outlined,
                          'Cart Shortcut',
                          onTap: () {
                            /* cart */
                          },
                        ),
                      ],
                    ),

                    // ======= Orders (with statuses + track) =======
                    ProfileSection(
                      title: 'Orders',
                      children: [
                        // Show statuses as compact row + tile for full order list
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
                                  trailing: Icon(
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
                                    width:
                                        300, // Adjusted viewport to show exactly 4 items
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      child: Row(
                                        children: [
                                          _orderStatus(
                                            'Processing',
                                            Icons.hourglass_bottom,
                                          ),
                                          const SizedBox(width: 14),
                                          _orderStatus(
                                            'Shipped',
                                            Icons.local_shipping,
                                          ),
                                          const SizedBox(width: 14),
                                          _orderStatus(
                                            'Delivered',
                                            Icons.check_circle_outline,
                                          ),
                                          const SizedBox(width: 14),
                                          _orderStatus(
                                            'Cancelled',
                                            Icons.cancel_outlined,
                                          ),
                                          const SizedBox(width: 14),
                                          _orderStatus('Returned', Icons.undo),
                                          const SizedBox(width: 14),
                                          _orderStatus(
                                            'Unpaid',
                                            Icons.payments_outlined,
                                          ),
                                          const SizedBox(width: 6),
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
                                duration: Duration(milliseconds: 180),
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
                                      offset: Offset(0, 3),
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

                    // ======= Offers & Wallet =======
                    ProfileSection(
                      title: 'Offers & Wallet',
                      children: [
                        profileOptionTile(
                          context,
                          Icons.local_offer_outlined,
                          'Coupons',
                          onTap: () {
                            /* coupons */
                          },
                        ),
                        profileOptionTile(
                          context,
                          Icons.card_giftcard,
                          'Gift Cards',
                          onTap: () {
                            /* gift cards */
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

                    // ======= Address & Delivery =======
                    ProfileSection(
                      title: 'Address & Delivery',
                      children: [
                        profileOptionTile(
                          context,
                          Icons.location_on_outlined,
                          'Address',
                          onTap: () {
                            /* open address manager */
                          },
                        ),
                      ],
                    ),

                    // ======= Payment =======
                    ProfileSection(
                      title: 'Payment',
                      children: [
                        profileOptionTile(
                          context,
                          Icons.payment,
                          'Payment Methods',
                          onTap: () {
                            /* open payment manager */
                          },
                        ),
                        profileOptionTile(
                          context,
                          Icons.account_balance_wallet_outlined,
                          'Payments / Wallet',
                          onTap: () {
                            /* wallet */
                          },
                        ),
                      ],
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
                          const Padding(
                            padding: EdgeInsets.only(left: 18.0, bottom: 6),
                            child: Text(
                              'App Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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
                                    Icons.color_lens_outlined,
                                    'Theme',
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.language,
                                    'Language',
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.public,
                                    'Country / Region',
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.currency_rupee,
                                    'Currency (INR)',
                                  ),
                                  profileOptionTile(
                                    context,
                                    Icons.notifications_none,
                                    'Notification Settings',
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
                          const Padding(
                            padding: EdgeInsets.only(left: 18.0, bottom: 6),
                            child: Text(
                              'Help & Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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
                      title: 'Privacy & Policies',
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

                    // ======= Logout button (scrollable element) =======
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
                          onPressed: () {
                            // replace with your login route
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0, bottom: 6),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Column(children: children),
        ],
      ),
    );
  }
}

// ===== Edit Profile Page (change username + change photo) =====
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