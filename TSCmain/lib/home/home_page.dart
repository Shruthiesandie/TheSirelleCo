// lib/home/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';
import '../pages/membership_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool arcOpen = false;

  // which icon is chosen after selecting from arc menu
  String selectedCategory = "none";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFFCEEEE),
          drawer: _drawer(),

          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: _buildTopBar(),
          ),

          body: Stack(
            children: [
              _buildSelectedPage(),

              // Arc menu floating
              PinterestArcMenu(
                isOpen: arcOpen,
                onMaleTap: () {
                  setState(() {
                    arcOpen = false;
                    selectedCategory = "male";
                  });
                },
                onFemaleTap: () {
                  setState(() {
                    arcOpen = false;
                    selectedCategory = "female";
                  });
                },
                onUnisexTap: () {
                  setState(() {
                    arcOpen = false;
                    selectedCategory = "unisex";
                  });
                },
              ),
            ],
          ),

          bottomNavigationBar: _bottomNav(),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // TOP BAR (ARC CLIPPED — EXACT LIKE YOUR ORIGINAL)
  // -------------------------------------------------------------------------
  Widget _buildTopBar() {
    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 90,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, size: 28, color: Colors.black),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            ),

            Expanded(
              child: Transform.translate(
                offset: const Offset(20, 0),
                child: SizedBox(
                  height: 80,
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
            )
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // DRAWER
  // -------------------------------------------------------------------------
  Drawer _drawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.pinkAccent),
            child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 22)),
          ),
          ListTile(title: Text("Profile")),
          ListTile(title: Text("Settings")),
          ListTile(title: Text("Orders")),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PAGE SWITCHER (HOME / MEMBERSHIP / CART / PROFILE)
  // -------------------------------------------------------------------------
  Widget _buildSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const Center(
          child: Text(
            "Home Page",
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
        );

      case 1:
        return const MembershipPage();

      case 2:
        return const CartPage();

      case 3:
        return const ProfilePage();

      default:
        return const Center(child: Text("Home"));
    }
  }

  // -------------------------------------------------------------------------
  // BOTTOM NAV BAR
  // -------------------------------------------------------------------------
  Widget _bottomNav() {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2)),
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
              _navIcon(Icons.shopping_cart, 2),
              _navIcon(Icons.person, 3),
            ],
          ),

          Positioned(
            bottom: 8,
            child: GestureDetector(
              onTap: () => setState(() => arcOpen = !arcOpen),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: Icon(
                  selectedCategory == "male"
                      ? Icons.male
                      : selectedCategory == "female"
                          ? Icons.female
                          : selectedCategory == "unisex"
                              ? Icons.transgender
                              : Icons.add,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // SINGLE NAV ICON
  // -------------------------------------------------------------------------
  Widget _navIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          arcOpen = false;
        });
      },
      child: Icon(
        icon,
        size: 28,
        color: selectedIndex == index ? Colors.pinkAccent : Colors.grey,
      ),
    );
  }
}

// -------------------------------------------------------------------------
// TOP BAR ARC CLIPPER
// -------------------------------------------------------------------------
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double curveHeight = 24;

    return Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + curveHeight,
        size.width,
        size.height - curveHeight,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
