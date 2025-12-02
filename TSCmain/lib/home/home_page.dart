// lib/home/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';
import '../pages/membership_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;
  bool arcOpen = false;
  String selectedCategory = "none";

  // Titles for each screen
  final List<String> pageTitles = [
    "Home",
    "Favourite",
    "All",
    "Cart",
    "Profile"
  ];

  // Pages
  final List<Widget> screens = const [
    Center(child: Text("Home Screen")),
    MembershipPage(),
    Center(child: Text("All Categories Screen")),
    CartPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFCEEEE),
      drawer: _drawer(),

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _topBar(),

                Expanded(
                  child: screens[selectedIndex],
                ),

                _bottomNavBar(),
              ],
            ),

            PinterestArcMenu(
              isOpen: arcOpen,
              onMaleTap: () => setCategory("male"),
              onFemaleTap: () => setCategory("female"),
              onUnisexTap: () => setCategory("unisex"),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // SET CATEGORY (ARC MENU SELECTION)
  // ---------------------------------------------------------
  void setCategory(String type) {
    setState(() {
      arcOpen = false;
      selectedCategory = type;
    });
  }

  // ---------------------------------------------------------
  // TOP BAR (CURVE + PAGE TITLE + MENU + ICONS)
  // ---------------------------------------------------------
  Widget _topBar() {
    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        height: 95,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Menu + Offer text
            Positioned(
              left: 0,
              top: 4,
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState!.openDrawer(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "offer available",
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.menu, size: 28, color: Colors.black),
                      onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                    ),
                  ],
                ),
              ),
            ),

            // Page title
            Positioned(
              top: 30,
              child: Text(
                pageTitles[selectedIndex],
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),

            // Right icons
            Positioned(
              right: 0,
              top: 12,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, size: 26),
                    onPressed: () => Navigator.pushNamed(context, "/search"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.workspace_premium, size: 26),
                    onPressed: () =>
                        Navigator.pushNamed(context, "/membership"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // BOTTOM NAVIGATION BAR — BEAUTIFUL + FIXED + PAGES SWITCH
  // ---------------------------------------------------------
  Widget _bottomNavBar() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, "Home", 0),
          _navItem(Icons.favorite_border, "favourite", 1),
          _navItem(Icons.grid_view, "All", 2),
          _navItem(Icons.shopping_cart, "cart", 3),
          _navItem(Icons.person, "Profile", 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          arcOpen = false;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: selectedIndex == index
                ? Colors.pinkAccent
                : Colors.grey.shade500,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: selectedIndex == index
                  ? Colors.pinkAccent
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // DRAWER WITH LOGOUT ADDED
  // ---------------------------------------------------------
  Drawer _drawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.pinkAccent),
            child: Text("Menu",
                style: TextStyle(color: Colors.white, fontSize: 22)),
          ),
          ListTile(
            title: const Text("Profile"),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
          const ListTile(title: Text("Settings")),
          ListTile(
            title: const Text("Orders"),
            onTap: () => Navigator.pushNamed(context, "/orders"),
          ),

          const Divider(),

          ListTile(
            title: const Text(
              "Logout",
              style:
                  TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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

// ---------------------------------------------------------
// TOP BAR WAVY CLIPPER
// ---------------------------------------------------------
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double curve = 40;

    return Path()
      ..lineTo(0, size.height - curve)
      ..quadraticBezierTo(
          size.width / 2, size.height + curve, size.width, size.height - curve)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
