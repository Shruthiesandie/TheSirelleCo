import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _arcOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // FULL TOP AREA WHITE (safe-area included)
      child: SafeArea(
        top: true,
        bottom: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFFCEEEE), // light pink background

          // ------------------------------
          // TOP NAV BAR (WHITE)
          // ------------------------------
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hamburger menu
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28, color: Colors.black),
                    onPressed: () {},
                  ),

                  // Center logo
                  Image.asset(
                    "assets/logo/logo.png",
                    height: 40,
                  ),

                  // Search + Heart
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

          // ------------------------------
          // BODY
          // ------------------------------
          body: Stack(
            children: [
              const Center(
                child: Text(
                  "Home Page",
                  style: TextStyle(fontSize: 22, color: Colors.black87),
                ),
              ),

              // Arc Menu overlay
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

          // ------------------------------
          // BOTTOM NAV BAR
          // ------------------------------
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: 2,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.pinkAccent,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              iconSize: 30,

              onTap: (index) {
                if (index == 2) {
                  setState(() => _arcOpen = !_arcOpen);
                }
              },

              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_filled), label: ""),
                BottomNavigationBarItem(
                    icon: Icon(Icons.card_membership), label: ""),

                /// PLUS ICON (CENTER BUTTON)
                BottomNavigationBarItem(
                  icon: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.pink,
                    child: Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                  label: "",
                ),

                BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart), label: ""),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: ""),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
