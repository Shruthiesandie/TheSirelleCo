// lib/pages/profile_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // add to pubspec
// import other packages as needed for your app routing/state management

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Replace with your real user state / provider
  String userName = 'Guest User';
  String membership = 'Non-Member';
  File? avatarFile;

  // theme helpers (matching drawer)
  Color get _accent => Colors.pink.shade600;
  Color get _muted => Colors.pink.shade50;
  Color get _textDark => Colors.pink.shade900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50.withOpacity(0.12),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _textDark,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w700)),
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
                    // ======= TOP PROFILE CARD (larger, spacious) =======
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 44,
                                  backgroundColor: _muted,
                                  backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null,
                                  child: avatarFile == null
                                      ? Icon(Icons.person, color: Colors.white, size: 38)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: _textDark),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _muted,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          membership,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: _accent,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
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
                                        if (result['avatarFile'] != null) avatarFile = result['avatarFile'] as File;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _muted),
                                      color: Colors.white,
                                    ),
                                    child: Text('Edit',
                                        style: TextStyle(
                                            color: _accent, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                _smallStat('Orders', '0'),
                                const SizedBox(width: 12),
                                _smallStat('Wishlist', '0'),
                                const SizedBox(width: 12),
                                _smallStat('Coupons', '0'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ======= My Account =======
                    ProfileSection(
                      title: 'My Account',
                      children: [
                        profileOptionTile(context, Icons.person_outline, 'Profile', onTap: () {/* open profile details */}),
                        profileOptionTile(context, Icons.card_giftcard, 'Coupons', onTap: () {/* open coupons */}),
                        profileOptionTile(context, Icons.location_on_outlined, 'Addresses', onTap: () {/* addresses */}),
                        profileOptionTile(context, Icons.favorite_border, 'Saved Items / Wishlist', onTap: () {/* wishlist */}),
                        profileOptionTile(context, Icons.shopping_cart_outlined, 'Cart Shortcut', onTap: () {/* cart */}),
                        profileOptionTile(context, Icons.account_balance_wallet_outlined, 'Payments / Wallet', onTap: () {/* wallet */}),
                      ],
                    ),

                    // ======= Orders (with statuses + track) =======
                    ProfileSection(
                      title: 'Orders',
                      children: [
                        // Show statuses as compact row + tile for full order list
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3))],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  leading: Container(
                                    height: 44, width: 44,
                                    decoration: BoxDecoration(color: _muted, borderRadius: BorderRadius.circular(12)),
                                    child: Icon(Icons.list_alt, color: _accent),
                                  ),
                                  title: Text('My Orders', style: TextStyle(fontWeight: FontWeight.w600, color: _textDark)),
                                  trailing: Icon(Icons.chevron_right, color: Colors.black26),
                                  onTap: () {/* open full orders page */},
                                ),
                                const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _orderStatus('Pending', Icons.hourglass_bottom),
                                      _orderStatus('Shipped', Icons.local_shipping),
                                      _orderStatus('Delivered', Icons.check_circle_outline),
                                      _orderStatus('Cancelled', Icons.cancel_outlined),
                                      _orderStatus('Returned', Icons.undo),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12, right: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _accent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          // track order action
                                        },
                                        icon: const Icon(Icons.map_outlined, size: 18),
                                        label: const Text('Track Order'),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ======= Wishlist / Recently Viewed =======
                    ProfileSection(
                      title: 'Wishlist',
                      children: [
                        profileOptionTile(context, Icons.favorite_border, 'Saved Items', onTap: () {/* saved */}),
                        profileOptionTile(context, Icons.history_toggle_off, 'Recently Viewed', onTap: () {/* recently viewed */}),
                      ],
                    ),

                    // ======= Address & Delivery =======
                    ProfileSection(
                      title: 'Address & Delivery',
                      children: [
                        profileOptionTile(context, Icons.location_on_outlined, 'Address', onTap: () {/* open address manager */}),
                      ],
                    ),

                    // ======= Payment =======
                    ProfileSection(
                      title: 'Payment',
                      children: [
                        profileOptionTile(context, Icons.payment, 'Payment Methods', onTap: () {/* open payment manager */}),
                      ],
                    ),

                    // ======= Offers & Wallet =======
                    ProfileSection(
                      title: 'Offers & Wallet',
                      children: [
                        profileOptionTile(context, Icons.local_offer_outlined, 'Coupons', onTap: () {/* coupons */}),
                        profileOptionTile(context, Icons.card_giftcard, 'Gift Cards', onTap: () {/* gift cards */}),
                        profileOptionTile(context, Icons.account_balance_wallet, 'App Wallet Balance', onTap: () {/* wallet balance */}),
                        profileOptionTile(context, Icons.loyalty_outlined, 'Rewards / Loyalty Points', onTap: () {/* rewards */}),
                      ],
                    ),


                    // ======= App Settings (expansion) =======
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 18.0, bottom: 6),
                            child: Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3))],
                              ),
                              child: ExpansionTile(
                                title: Text('Preferences', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark)),
                                iconColor: _accent,
                                collapsedIconColor: Colors.black26,
                                childrenPadding: const EdgeInsets.only(bottom: 12),
                                children: [
                                  profileOptionTile(context, Icons.color_lens_outlined, 'Theme'),
                                  profileOptionTile(context, Icons.language, 'Language'),
                                  profileOptionTile(context, Icons.public, 'Country / Region'),
                                  profileOptionTile(context, Icons.currency_rupee, 'Currency (INR)'),
                                  profileOptionTile(context, Icons.notifications_none, 'Notification Settings'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======= Help & Information (dropdown) =======
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 18.0, bottom: 6),
                            child: Text('Help & Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3))],
                              ),
                              child: ExpansionTile(
                                title: Text('Help & Info', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.pink)),
                                children: [
                                  profileOptionTile(context, Icons.help_outline, 'Help Center'),
                                  profileOptionTile(context, Icons.report_problem_outlined, 'Report an issue'),
                                  profileOptionTile(context, Icons.chat_bubble_outline, 'Chat with Support'),
                                  profileOptionTile(context, Icons.description_outlined, 'Terms & Conditions'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======= Privacy Policies (single option) =======
                    ProfileSection(
                      title: 'Privacy & Policies',
                      children: [
                        profileOptionTile(context, Icons.policy, 'Privacy & Policies', onTap: () {/* open policies page */}),
                      ],
                    ),

                    // ======= About the App =======
                    ProfileSection(
                      title: 'About',
                      children: [
                        profileOptionTile(context, Icons.info_outline, 'About Us'),
                        profileOptionTile(context, Icons.privacy_tip_outlined, 'App Version', subtitle: '1.0.0'),
                      ],
                    ),

                    // ======= Logout button (scrollable element) =======
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: _accent, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            // replace with your login route
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text('Log Out', style: TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 15)),
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
  Widget _smallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: _textDark)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.black45, fontSize: 12)),
      ],
    );
  }

  Widget _orderStatus(String label, IconData icon) {
    return Column(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(color: _muted, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _accent, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// Reusable tile widget
Widget profileOptionTile(BuildContext context, IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
  final Color accent = Colors.pink.shade600;
  final Color muted = Colors.pink.shade50;
  final Color textDark = Colors.pink.shade900;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3))],
      ),
      child: ListTile(
        minVerticalPadding: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(color: muted, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: accent, size: 22),
        ),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textDark)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
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
  const ProfileSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(left: 18.0, bottom: 6), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
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
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
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
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.w700)),
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
                backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null,
                child: avatarFile == null ? const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 36) : null,
              ),
            ),

            const SizedBox(height: 30),

            // Username Field (ONLY username allowed)
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  Navigator.pop(context, {'username': usernameController.text, 'avatarFile': avatarFile});
                },
                child: const Text("Save", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
