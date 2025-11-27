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

  // ⭐ Added for hamburger menu to work
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ⭐ NEW — Pages for bottom navigation switching
  final List<Widget> pages = const [
    Center(child: Text("Home Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("Membership Page", style: TextStyle(fontSize: 22))),
    SizedBox(), // placeholder for plus button
    Center(child: Text("Cart Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("Profile Page", style: TextStyle(fontSize: 22))),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Scaffold(
          key: _scaffoldKey,  // ⭐ required for drawer

          backgroundColor: const Color(0xFFFCEEEE), // Pink bg

          // ⭐ DRAWER ADDED
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                  ),
                  child: Text(
                    "Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
                ListTile(title: Text("Profile")),
                ListTile(title: Text("Settings")),
                ListTile(title: Text("Orders")),
              ],
            ),
          ),

          // ---------------- TOP BAR ----------------
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: ClipPath(
              clipper: TopBarClipper(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, size: 28, color: Colors.black),
                      onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                    ),

                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(100, 0),
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Image.asset("assets/logo/logo.png"),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, size: 26, color: Colors.black),
                          onPressed: () => Navigator.pushNamed(context, "/search"),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border,
                              size: 26, color: Colors.black),
                          onPressed: () => Navigator.pushNamed(context, "/love"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---------------- BODY (updated navigation) ----------------
          body: Stack(
            children: [
              pages[_selected],  // ⭐ SWITCH PAGES HERE

              PinterestArcMenu(
                isOpen: _arcOpen,
                onMaleTap: () => setState(() => _arcOpen = false),
                onFemaleTap: () => setState(() => _arcOpen = false),
                onUnisexTap: () => setState(() => _arcOpen = false),
              ),
            ],
          ),

          // ---------------- BOTTOM NAV ----------------
          bottomNavigationBar: _buildAestheticNavBar(),
        ),
      ),
    );
  }

  // ---------------- NAV BAR ----------------
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navIcon(Icons.home_filled, 0),
              _navIcon(Icons.card_membership, 1),
              const SizedBox(width: 60),
              _navIcon(Icons.shopping_cart, 3),
              _navIcon(Icons.person, 4),
            ],
          ),

          Positioned(
            bottom: 8,
            child: GestureDetector(
              onTap: () => setState(() => _arcOpen = !_arcOpen),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ICON LOGIC UPDATED ----------------
  Widget _navIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        if (index == 2) return; // plus icon handled separately

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

// ---------------- CURVED TOP BAR ----------------
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double curveHeight = 24;

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + curveHeight,
        size.width,
        size.height - curveHeight,
      )
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
