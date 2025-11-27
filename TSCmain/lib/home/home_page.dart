import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _arcOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // -------------------------------
      // TOP NAV BAR
      // -------------------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hamburger
                const Icon(Icons.menu, size: 28),

                // Center logo
                const Icon(Icons.favorite, size: 30, color: Colors.black),

                // Search + Favorite
                Row(
                  children: const [
                    Icon(Icons.search, size: 26),
                    SizedBox(width: 16),
                    Icon(Icons.favorite_border, size: 26),
                  ],
                )
              ],
            ),
          ),
        ),
      ),

      // -------------------------------
      // BODY + ARC MENU OVERLAY
      // -------------------------------
      body: Stack(
        children: [
          // Simple placeholder
          const Center(
            child: Text(
              "HOME PAGE",
              style: TextStyle(fontSize: 26),
            ),
          ),

          // ARC MENU
          PinterestArcMenu(
            isOpen: _arcOpen,
            onMaleTap: () {},
            onFemaleTap: () {},
            onUnisexTap: () {},
          ),
        ],
      ),

      // -------------------------------
      // BOTTOM NAV BAR
      // -------------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 28,
        onTap: (index) {
          if (index == 2) {
            // Center + button → toggle arc
            setState(() => _arcOpen = !_arcOpen);
            return;
          }
          setState(() {
            _selectedIndex = index;
            _arcOpen = false;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.card_membership), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 34), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}
