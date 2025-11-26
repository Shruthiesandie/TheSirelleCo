// lib/home/pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

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
        return const Center(child: Text("All Categories Placeholder"));
      case 3:
        return const Center(child: Text("Cart Page"));
      case 4:
        return const Center(child: Text("Profile Page"));
      default:
        return const Center(child: Text("Home Page"));
    }
  }

  void _openCategory(String slug) {
    if (slug == "close") {
      setState(() => _menuOpen = false);
      return;
    }
    setState(() => _menuOpen = false);
    Navigator.pushNamed(context, "/category/$slug");
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;

    // Number of bottom nav items (update if you change the bar)
    const int itemsCount = 5;

    // index of your center grid icon (0-based). Here it's the 3rd item: index 2.
    const int centerIndex = 2;

    // width of each item (approx)
    final double itemWidth = screenW / itemsCount;

    // center x of the target item (we add a small manual shift option if needed)
    // If your BottomNavigationBar has extra internal padding, tweak anchorShift.
    const double anchorShift = 0.0; // <- adjust this (positive moves arc right)
    final double anchorX = (itemWidth * centerIndex) + (itemWidth / 2) + anchorShift;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
        ),
        child: ListView(padding: EdgeInsets.zero, children: const [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFFC1E3), Color(0xFFB4F8C8)]),
            ),
            child: Text("Hello, User 🎀", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.white,
          child: SafeArea(
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.menu, size: 28, color: Colors.black), onPressed: () => _scaffoldKey.currentState!.openDrawer()),
                Expanded(child: Center(child: Image.asset("assets/logo/logo.png", height: 70, width: 70, fit: BoxFit.contain))),
                Row(children: [
                  IconButton(icon: const Icon(Icons.search, size: 26, color: Colors.black), onPressed: () => Navigator.pushNamed(context, "/search")),
                  IconButton(icon: const Icon(Icons.favorite, size: 26, color: Colors.black), onPressed: () => Navigator.pushNamed(context, "/love")),
                ])
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(child: _getPage(_selectedIndex)),

          // Pass the anchorX so the arc is wrapped around the grid icon
          PinterestArcMenu(
            isOpen: _menuOpen,
            onSelect: _openCategory,
            anchorX: anchorX,
            bottomOffset: kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom - 6,
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 28,
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
