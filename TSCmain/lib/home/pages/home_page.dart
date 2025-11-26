// lib/home/pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/popup_circular_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _menuOpen = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ---------------- PAGE NAVIGATION ----------------
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const Center(child: Text("Home Page"));
      case 1:
        return const Center(child: Text("Membership Page"));
      case 2:
        return const Center(child: Text("All Categories Placeholder"));
      case 3:
        return const Center(child: Text("Cart Page"));
      case 4:
        return const Center(child: Text("Profile Page"));
      default:
        return const Center(child: Text("Home Page"));
    }
  }

  // ---------------- HANDLE CATEGORY SELECTION ----------------
  void _openCategory(String slug) {
    setState(() => _menuOpen = false);
    Navigator.pushNamed(context, "/category/$slug");
  }

  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // ---------------- DRAWER ----------------
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFC1E3), Color(0xFFB4F8C8)],
                ),
              ),
              child: Text(
                "Hello, User 🎀",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),

      // ---------------- TOP APP BAR ----------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.white,
          child: SafeArea(
            child: Row(
              children: [
                // MENU BUTTON
                IconButton(
                  icon: const Icon(Icons.menu, size: 28, color: Colors.black),
                  onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                ),

                // CENTER LOGO
                Expanded(
                  child: Center(
                    child: Image.asset(
                      "assets/logo/logo.png",
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // RIGHT SIDE ICONS
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search, size: 26, color: Colors.black),
                      onPressed: () => Navigator.pushNamed(context, "/search"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, size: 26, color: Colors.black),
                      onPressed: () => Navigator.pushNamed(context, "/love"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // ---------------- BODY + POPUP OVERLAY ----------------
      body: Stack(
        children: [
          Positioned.fill(child: _getPage(_selectedIndex)),

          // Popup bubble menu
          PopupBubbleMenu(
            isOpen: _menuOpen,
            onSelect: _openCategory,
            onClose: () => setState(() => _menuOpen = false),
          ),
        ],
      ),

      // ---------------- BOTTOM NAV BAR ----------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 28,

        // ----- NAVIGATION & POPUP CONTROL -----
        onTap: (index) {
          if (index == 2) {
            // CENTER ITEM TRIGGERS POPUP
            setState(() => _menuOpen = !_menuOpen);
            return;
          }

          setState(() {
            _selectedIndex = index;
            _menuOpen = false;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.card_membership), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ""), // CENTER TRIGGER
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}
