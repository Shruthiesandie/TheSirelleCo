// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../pages/profile_page.dart';
import '../../pages/login_page.dart';

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
                    Padding(
                      padding: const EdgeInsets.only(left:18, right:18, top:28, bottom:18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical:24, horizontal:18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.85),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.pink.shade100.withOpacity(.3), blurRadius: 12, offset: const Offset(0,4))],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.pink.shade200.withOpacity(0.6),
                              child: const Icon(Icons.person, size: 30, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Text(
                                  "Guest User",
                                  style: TextStyle(fontSize:18, fontWeight: FontWeight.bold, color: Colors.pink.shade700),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal:8, vertical:4),
                                  decoration: BoxDecoration(
                                    color: Colors.pink.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Non‑Member",
                                    style: TextStyle(fontSize:12, color: Colors.pink.shade700),
                                  ),
                                )
                              ]
                            )
                          ]
                        )
                      )
                    ),

                    const SizedBox(height: 12),

                    drawerItem(context, Icons.person, "My Profile"),
                    const SizedBox(height: 2),
                    drawerItem(context, Icons.shopping_bag, "Orders"),
                    const SizedBox(height: 2),
                    drawerItem(context, Icons.dashboard, "Dashboard"),
                    const SizedBox(height: 2),
                    drawerItem(context, Icons.sports_esports, "Game or Your Fairy (Contact Us)"),
                    const SizedBox(height: 2),
                    drawerItem(context, Icons.settings, "Settings"),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 18,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Follow us on",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      socialIcon(Icons.camera_alt_outlined),
                      const SizedBox(width: 10),
                      socialIcon(Icons.facebook),
                      const SizedBox(width: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: InkWell(
        onTap: () {
          if (title == "Profile" || title == "My Profile") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.78),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.shade100.withOpacity(.22),
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: ListTile(
            dense: true,
            minVerticalPadding: 0,
            leading: Icon(icon, color: Colors.pink.shade400),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.pink.shade900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget socialIcon(IconData icon){
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.8),
        boxShadow:[BoxShadow(color: Colors.pink.shade100.withOpacity(.3), blurRadius:8)]
      ),
      child: Icon(icon, color: Colors.pink.shade600, size:22),
    );
  }
}