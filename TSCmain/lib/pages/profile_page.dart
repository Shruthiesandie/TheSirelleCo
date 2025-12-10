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
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 60),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.pink.shade50.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(22),
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
                      radius: 40,
                      backgroundColor: _muted,
                      child: Icon(Icons.person, color: Colors.white, size: 34),
                    ),
                    const SizedBox(width: 18),
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
                          const SizedBox(height: 10),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfilePage()),
                        );
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
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8).copyWith(bottom: 20),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0, bottom: 6),
                            child: Text(
                              "Settings & App",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                                ],
                              ),
                              child: ExpansionTile(
                                title: Text("Settings", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.pink.shade900)),
                                iconColor: Colors.pink.shade600,
                                collapsedIconColor: Colors.black26,
                                childrenPadding: const EdgeInsets.only(bottom: 12),
                                children: [
                                  profileOptionTile(context, Icons.notifications_none, 'Notifications'),
                                  profileOptionTile(context, Icons.language, 'Language'),
                                  profileOptionTile(context, Icons.color_lens_outlined, 'Theme'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                                ],
                              ),
                              child: ExpansionTile(
                                title: Text("Support & About", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.pink.shade900)),
                                iconColor: Colors.pink.shade600,
                                collapsedIconColor: Colors.black26,
                                childrenPadding: const EdgeInsets.only(bottom: 12),
                                children: [
                                  profileOptionTile(context, Icons.help_outline, 'Help Center'),
                                  profileOptionTile(context, Icons.phone_in_talk_outlined, 'Contact Support'),
                                  profileOptionTile(context, Icons.info_outline, 'Terms & Conditions'),
                                  profileOptionTile(context, Icons.privacy_tip_outlined, 'Privacy Policy'),
                                  profileOptionTile(context, Icons.system_update_alt, 'App Version', subtitle: '1.0.0'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, "/login");
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

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

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
              onTap: () {
                // TODO: add image picker logic
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.pink.shade200,
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 30),

            // Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Username Field
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
                  Navigator.pop(context);
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
            )
          ],
        ),
      ),
    );
  }
}