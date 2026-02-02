import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../pages/profile_page.dart';
import '../../pages/sirelle_chat_page.dart';


class HomeDrawer extends StatelessWidget {
  final VoidCallback onProfileTap;
  final bool isGuest;

  const HomeDrawer({
    super.key,
    required this.onProfileTap,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Drawer(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 255, 173, 185).withOpacity(0.85),
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Card
                    Padding(
                      padding: const EdgeInsets.only(left:18, right:18, top:28, bottom:18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.pop(context); // close drawer
                          Future.delayed(const Duration(milliseconds: 150), () {
                            if (isGuest) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                "/login",
                                (route) => false,
                              );
                            } else {
                              onProfileTap();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical:20, horizontal:18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 42,
                                backgroundColor: const Color.fromARGB(255, 241, 177, 205).withOpacity(0.7),
                                child: Icon(Icons.person, size: 30, color: Colors.white),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StreamBuilder<User?>(
                                      stream: FirebaseAuth.instance.authStateChanges(),
                                      builder: (context, snapshot) {
                                        final user = snapshot.data;

                                        final displayName = isGuest
                                            ? "Guest User"
                                            : user?.displayName?.isNotEmpty == true
                                                ? "@${user!.displayName!}"
                                                : user?.email ?? "User";

                                        return Text(
                                          displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.pink.shade700,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 6),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal:10, vertical:4),
                                      decoration: BoxDecoration(
                                        color: Colors.pink.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Non‑Member",
                                        style: TextStyle(fontSize: 12, color: Colors.pink.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    if (isGuest)
                      drawerItem(context, Icons.login, "Login")
                    else ...[
                      drawerItem(context, Icons.person, "My Profile"),
                      SizedBox(height: 1),
                      drawerItem(context, Icons.shopping_bag, "Orders"),
                    ],
                    SizedBox(height: 1),
                    drawerItem(context, Icons.card_giftcard, "Coupons"),
                    SizedBox(height: 1),
                    drawerItem(context, Icons.sports_esports, "Games"),
                    SizedBox(height: 1),
                    drawerItem(context, Icons.wb_twighlight, "Sirelle-chan"),
                    SizedBox(height: 1),
                    drawerItem(context, Icons.settings, "Settings"),

                    SizedBox(height: 80), // Space before social section
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Follow us on",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 255, 196, 222),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      socialIcon(FontAwesomeIcons.instagram),
                      SizedBox(width: 16),
                      socialIcon(FontAwesomeIcons.facebookF),
                      SizedBox(width: 16),
                      socialIcon(FontAwesomeIcons.youtube),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerItem(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 243, 246),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: ListTile(
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 239, 244, 240),
              borderRadius: BorderRadius.circular(12),
            ),
            child: title == "Sirelle-chan"
                ? Icon(Icons.auto_awesome, color: Colors.pink.shade600, size: 22)
                : Icon(icon, color: Colors.pink.shade600),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 7, 41, 10),
            ),
          ),
          onTap: () {
            Navigator.pop(context); // close drawer first

            Future.delayed(const Duration(milliseconds: 150), () {
              if (title == "My Profile" || title == "Profile") {
                onProfileTap();
              }

              if (title == "Login") {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (route) => false,
                );
              }

              if (title == "Coupons") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(openCoupons: true),
                  ),
                );
              }
              if (title == "Sirelle-chan") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SirelleChatPage(),
                  ),
                );
              }
            });
          },
        ),
      ),
    );
  }

  Widget socialIcon(IconData icon){
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 20,
        color: icon == FontAwesomeIcons.instagram
            ? const Color(0xFFE1306C) // Instagram
            : icon == FontAwesomeIcons.facebookF
                ? const Color(0xFF1877F2) // Facebook
                : const Color(0xFFFF0000), // YouTube
      ),
    );
  }
}