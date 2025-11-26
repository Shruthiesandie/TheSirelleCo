import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Page navigation handler
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const Center(child: Text("Home Page"));
      case 1:
        return const Center(child: Text("Membership Page"));
      case 2:
        return const Center(child: Text("All Categories Page"));
      case 3:
        return const Center(child: Text("Cart Page"));
      case 4:
        return const Center(child: Text("Profile Page"));
      default:
        return const Center(child: Text("Home Page"));
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),

      // -------------------- CUSTOM TOP BAR --------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90), // bigger AppBar
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.white,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hamburger
                IconButton(
                  icon: const Icon(Icons.menu, size: 28, color: Colors.black),
                  onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                ),

                // -------------------- LOGO --------------------
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.pinkAccent.withOpacity(0.35),
                    ), // debug border
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    "assets/logo/logo.png",
                    height: 70,   // <— CHANGE THIS to resize logo
                    width: 70,    // <— keep equal for perfect scaling
                    fit: BoxFit.contain,
                  ),
                ),

                // Search + Love
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

      // -------------------- BODY --------------------
      body: _getPage(_selectedIndex),

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
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.card_membership), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}
