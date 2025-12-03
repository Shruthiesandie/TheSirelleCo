import 'package:flutter/material.dart';
import '../../pages/profile_page.dart';
import '../../pages/login_page.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.pinkAccent),
            child: Text(
              "Menu",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text("Orders"),
            onTap: () => Navigator.pushNamed(context, "/orders"),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}