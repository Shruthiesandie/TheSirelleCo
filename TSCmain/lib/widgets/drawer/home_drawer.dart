// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../pages/profile_page.dart';


class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

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
                      Colors.white.withOpacity(0.85),
                      Colors.pink.shade50.withOpacity(0.95),
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
                              radius: 28,
                              backgroundColor: Colors.pink.shade200.withOpacity(0.7),
                              child: Icon(Icons.person, size: 30, color: Colors.white),
                            ),
                            SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Guest User",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.pink.shade700,
                                  ),
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
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    drawerItem(context, Icons.person, "My Profile"),
                    SizedBox(height: 1),
                    drawerItem(context, Icons.shopping_bag, "Orders"),
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
                      color: Colors.pink.shade800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      socialIcon(Icons.camera_alt_outlined), // placeholder IG icon
                      SizedBox(width: 16),
                      socialIcon(Icons.facebook),
                      SizedBox(width: 16),
                      socialIcon(Icons.play_circle_fill),
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
          color: Colors.white,
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
              color: Colors.pink.shade50,
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
              color: Colors.pink.shade900,
            ),
          ),
          onTap: () {
            if (title == "My Profile" || title == "Profile") {
              Navigator.pop(context); // Close drawer first to avoid dark overlay
              Future.delayed(const Duration(milliseconds: 150), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              });
            }
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
      child: Icon(icon, color: Colors.pink.shade700, size: 20),
    );
  }
}