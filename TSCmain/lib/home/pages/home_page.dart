import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

      // -------------------- APP BAR CUSTOM SECTION --------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hamburger Menu
              IconButton(
                icon: const Icon(Icons.menu, size: 28, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),

              // Center Logo
              SizedBox(
                height: 40,
                child: Image.asset("assets/logo/logo.png"), // <-- your logo
              ),

              // Right Icons (Search + Favourites)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search,
                        size: 26, color: Colors.black87),
                    onPressed: () => Navigator.pushNamed(context, "/search"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite,
                        size: 26, color: Colors.black87),
                    onPressed: () =>
                        Navigator.pushNamed(context, "/favourites"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // -------------------- PAGE BODY --------------------
      body: _getPage(_selectedIndex),

      // -------------------- BOTTOM NAV BAR --------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        iconSize: 28,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: "Membership",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
