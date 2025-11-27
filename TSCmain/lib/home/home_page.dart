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
    return Container(
      color: Colors.white, // FULL WHITE TOP SAFE AREA
      child: SafeArea(
        top: true,
        bottom: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFFCEEEE), // aesthetic pink

          // ------------------- TOP BAR -------------------
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28, color: Colors.black),
                    onPressed: () {},
                  ),

                  Image.asset("assets/logo/logo.png", height: 40),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search,
                            size: 26, color: Colors.black),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border,
                            size: 26, color: Colors.black),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ------------------- PAGE BODY -------------------
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
                onMaleTap: () {
                  setState(() => _arcOpen = false);
                },
                onFemaleTap: () {
                  setState(() => _arcOpen = false);
                },
                onUnisexTap: () {
                  setState(() => _arcOpen = false);
                },
              ),
            ],
          ),

          // ------------------- BOTTOM NAV -------------------
          bottomNavigationBar: _buildAestheticNavBar(),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // ⭐ RESTORED OLD AESTHETIC BOTTOM NAV BAR
  // -------------------------------------------------------
  Widget _buildAestheticNavBar() {
    return Container(
      height: 74,
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

      // All icons including PLUS will be centered manually
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The row behind
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navIcon(Icons.home_filled, 0),
              _navIcon(Icons.card_membership, 1),
              const SizedBox(width: 60), // space for the FAB
              _navIcon(Icons.shopping_cart, 3),
              _navIcon(Icons.person, 4),
            ],
          ),

          // CENTER PLUS BUTTON (Floating)
          Positioned(
            bottom: 16,
            child: GestureDetector(
              onTap: () {
                setState(() => _arcOpen = !_arcOpen);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 25, color: Colors.white),
              ),
            ),
          ),
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
