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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
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

                  drawerItem(context, Icons.person, "My Profile"),
                  drawerItem(context, Icons.shopping_bag, "Orders"),
                  drawerItem(context, Icons.dashboard, "Dashboard"),
                  drawerItem(context, Icons.sports_esports, "Game or Your Fairy (Contact Us)"),
                  drawerItem(context, Icons.settings, "Settings"),

                  Padding(
                    padding: const EdgeInsets.only(left:18, bottom:10),
                    child: Text(
                      "Follow us on",
                      style: TextStyle(fontSize:14, fontWeight: FontWeight.w600, color: Colors.pink.shade900),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      socialIcon(Icons.camera_alt),
                      const SizedBox(width:14),
                      socialIcon(Icons.facebook),
                      const SizedBox(width:14),
                      socialIcon(Icons.play_circle_fill),
                    ],
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.pinkAccent,
                              Color(0xFFB97BFF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Log Out",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        onTap: () {
          if (title == "My Profile" || title == "Profile") {
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
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ListTile(
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