import 'package:flutter/material.dart';
import '../widgets/half_circle_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _menuOpen = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const Center(child: Text("Home Page"));
      case 1:
        return const Center(child: Text("Membership Page"));
      case 2:
        return const Center(child: Text("All Categories (placeholder)"));
      case 3:
        return const Center(child: Text("Cart Page"));
      case 4:
        return const Center(child: Text("Profile Page"));
      default:
        return const Center(child: Text("Home Page"));
    }
  }

  void _closeMenu() => setState(() => _menuOpen = false);

  void _onCategorySelect(String slug) {
    _closeMenu();
    if (slug == 'male') {
      Navigator.pushNamed(context, '/category/male');
    } else if (slug == 'female') {
      Navigator.pushNamed(context, '/category/female');
    } else {
      Navigator.pushNamed(context, '/category/all');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // -------------------- DRAWER --------------------
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
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),

      // -------------------- TOP APP BAR --------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.white,
          child: SafeArea(
            child: Row(
              children: [
                // Sidebar menu icon
                IconButton(
                  icon: const Icon(Icons.menu,
                      size: 28, color: Colors.black),
                  onPressed: () =>
                      _scaffoldKey.currentState!.openDrawer(),
                ),

                // CENTER LOGO
               Expanded(
  child: Transform.translate(
    offset: const Offset(25, 0), // ← SHIFT LOGO (x , y)
    child: Center(
      child: Image.asset(
        "assets/logo/logo.png",
        height: 95,
        width: 95,
        fit: BoxFit.contain,
      ),
    ),
  ),
),


                // Right icons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search,
                          size: 26, color: Colors.black),
                      onPressed: () =>
                          Navigator.pushNamed(context, "/search"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite,
                          size: 26, color: Colors.black),
                      onPressed: () =>
                          Navigator.pushNamed(context, "/love"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // -------------------- BODY + SEMICIRCLE STACK --------------------
      body: Stack(
        children: [
          Positioned.fill(child: _getPage(_selectedIndex)),

          // semicircle overlay
          HalfCircleMenu(
            isOpen: _menuOpen,
            radius: 140,
            onSelect: _onCategorySelect,
            onClose: _closeMenu,
          ),
        ],
      ),

      // -------------------- BOTTOM NAV --------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        iconSize: 28,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 2) {
            setState(() => _menuOpen = !_menuOpen);
            return;
          }
          setState(() {
            _selectedIndex = index;
            _menuOpen = false;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_membership), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}
