import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selected = 0;
  bool _arcOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9E1D9), // same aesthetic as splash 😍

      // ---------------- TOP NAV -----------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, size: 28, color: Colors.black),

                // Center icon/logo
                Image.asset(
                  "assets/logo/logo.png",
                  height: 40,
                ),

                Row(
                  children: const [
                    Icon(Icons.search, size: 26, color: Colors.black),
                    SizedBox(width: 18),
                    Icon(Icons.favorite_border, size: 26, color: Colors.black),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // ---------------- BODY + ARC -----------------
      body: Stack(
        children: [
          const Center(
            child: Text(
              "Home Page",
              style: TextStyle(fontSize: 22, color: Colors.black87),
            ),
          ),

          PinterestArcMenu(
            isOpen: _arcOpen,
            onMaleTap: () {},
            onFemaleTap: () {},
            onUnisexTap: () {},
          ),
        ],
      ),

      // ---------------- BOTTOM BAR -----------------
      bottomNavigationBar: _buildAestheticNavBar(),
    );
  }

  Widget _buildAestheticNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(Icons.home, 0),
          _navIcon(Icons.card_membership, 1),

          // PLUS BUTTON
          GestureDetector(
            onTap: () {
              setState(() => _arcOpen = !_arcOpen);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          _navIcon(Icons.shopping_cart, 3),
          _navIcon(Icons.person, 4),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = index;
          _arcOpen = false;
        });
      },
      child: Icon(
        icon,
        size: 28,
        color: _selected == index ? Colors.pinkAccent : Colors.grey,
      ),
    );
  }
}
