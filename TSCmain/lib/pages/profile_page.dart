// lib/pages/profile_page.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Theme helpers so it's easy to match the drawer
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
            // Top header card (fixed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: _muted,
                      child: Icon(Icons.person, color: Colors.white, size: 34),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guest User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _muted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Non-Member',
                              style: TextStyle(fontSize: 12, color: _accent),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Edit button
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // TODO: Navigate to edit profile screen
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _muted),
                          color: Colors.white,
                        ),
                        child: Text('Edit', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Body (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Column(
                  children: [
                    // My Account Section
                    ProfileSection(
                      title: 'My Account',
                      children: [
                        profileOptionTile(context, Icons.person, 'Profile', onTap: () {/* open profile details */}),
                        profileOptionTile(context, Icons.card_giftcard, 'Coupons', onTap: () {/* open coupons */}),
                        profileOptionTile(context, Icons.location_on_outlined, 'Addresses', onTap: () {/* open addresses */}),
                        profileOptionTile(context, Icons.favorite_border, 'Saved Items / Wishlist', onTap: () {/* wishlist */}),
                        profileOptionTile(context, Icons.account_balance_wallet_outlined, 'Payments / Wallet', onTap: () {/* wallet */}),
                      ],
                    ),

                    // Orders Section
                    ProfileSection(
                      title: 'Orders',
                      children: [
                        profileOptionTile(context, Icons.hourglass_bottom, 'Processing Orders', onTap: () {/* processing */}),
                        profileOptionTile(context, Icons.history, 'Order History', onTap: () {/* history */}),
                        profileOptionTile(context, Icons.undo, 'Returns / Refund Requests', onTap: () {/* returns */}),
                      ],
                    ),

                    // Settings & Support Section
                    ProfileSection(
                      title: 'Settings & App',
                      children: [
                        profileOptionTile(context, Icons.notifications_none, 'Notifications', onTap: () {/* notifications */}),
                        profileOptionTile(context, Icons.language, 'Language', onTap: () {/* language */}),
                        profileOptionTile(context, Icons.color_lens_outlined, 'Theme', onTap: () {/* theme */}),
                        profileOptionTile(context, Icons.help_outline, 'Help Center', onTap: () {/* help */}),
                        profileOptionTile(context, Icons.phone_in_talk_outlined, 'Contact Support', onTap: () {/* contact */}),
                        profileOptionTile(context, Icons.info_outline, 'Terms & Conditions', onTap: () {/* terms */}),
                        profileOptionTile(context, Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {/* privacy */}),
                        profileOptionTile(context, Icons.system_update_alt, 'App Version', subtitle: '1.0.0', onTap: () {/* version */}),
                      ],
                    ),

                    const SizedBox(height: 28), // breathing room above logout
                  ],
                ),
              ),
            ),

            // Logout button (fixed bottom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: _accent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    // TODO: log out action
                  },
                  child: Text('Log Out', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileOptionTile(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
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
              color: _muted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _accent, size: 22),
          ),
          title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark)),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
          trailing: Icon(Icons.chevron_right, color: Colors.black26),
          onTap: onTap,
        ),
      ),
    );
  }
}

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