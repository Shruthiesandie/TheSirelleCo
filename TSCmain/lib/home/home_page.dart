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

  final List<String> pageTitles = [
    "Home",
    "Favourite",
    "All",
    "Cart",
    "Profile"
  ];

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
                _buildTitleBar(),

                Expanded(child: screens[selectedIndex]),

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

  void setCategory(String type) {
    setState(() {
      arcOpen = false;
      selectedCategory = type;
    });
  }

  // ---------------------------------------------------------
  // TOP BAR SWITCHER
  // ---------------------------------------------------------
  Widget _buildTitleBar() {
    if (selectedIndex == 0) {
      // HOME SCREEN — BIG CURVED BAR WITH LOGO
      return ClipPath(
        clipper: TopBarClipper(),
        child: Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left menu + offer text
              Positioned(
                left: 0,
                top: 4,
                child: GestureDetector(
                  onTap: () => _scaffoldKey.currentState!.openDrawer(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("offer available",
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w500)),
                      IconButton(
                        icon: const Icon(Icons.menu,
                            size: 28, color: Colors.black),
                        onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                      ),
                    ],
                  ),
                ),
              ),

              // LOGO IN MIDDLE
              Positioned(
                top: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.6),
                  ),
                  child: Image.asset(
                    "assets/logo/logo.png",
                    height: 38,
                    width: 38,
                    fit: BoxFit.contain,
                  ),
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
    } else {
      // OTHER SCREENS — SIMPLE RECT BAR WITH TITLE + ROUNDED CORNERS
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                icon: const Icon(Icons.menu)),

            Text(
              pageTitles[selectedIndex],
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(width: 48), // keeps title centered
          ],
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // BOTTOM NAV BAR — ICONS NAVIGATE BUT BAR STAYS
  // ---------------------------------------------------------
  Widget _bottomNavBar() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
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
  // DRAWER WITH LOGOUT INCLUDED
  // ---------------------------------------------------------
  Drawer _drawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.pinkAccent),
            child:
                Text("Menu", style: TextStyle(color: Colors.white, fontSize: 22)),
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
// CLIPPER FOR CURVED HOME TOP BAR
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
