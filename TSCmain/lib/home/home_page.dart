import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  int _selected = 0;
  bool _arcOpen = false;

  String _selectedCategory = "none";

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

          // ----------------------------------------------------------------------
          // Drawer
          // ----------------------------------------------------------------------
          drawer: _buildPremiumDrawer(),

          // ----------------------------------------------------------------------
          // ⭐ FIXED PREMIUM TOP BAR (same alignment, enhanced visuals)
          // ----------------------------------------------------------------------
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: ClipPath(
              clipper: TopBarClipper(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.85),
                      Colors.white.withOpacity(0.98),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // MENU BUTTON
                    _glassIconButton(
                      Icons.menu,
                      () => _scaffoldKey.currentState!.openDrawer(),
                    ),

                    // LOGO (same exact alignment)
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(100, 0),
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              "assets/logo/logo.png",
                              fit: BoxFit.contain,
                              // ✔ fixes white background problem
                              color: null,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // SEARCH + LOVE buttons
                    Row(
                      children: [
                        _glassIconButton(
                          Icons.search,
                          () => Navigator.pushNamed(context, "/search"),
                        ),
                        const SizedBox(width: 10),
                        _glassIconButton(
                          Icons.favorite_border,
                          () => Navigator.pushNamed(context, "/love"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ----------------------------------------------------------------------
          // BODY
          // ----------------------------------------------------------------------
          body: Stack(
            children: [
              const Center(
                child: Text(
                  "Home Page",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              PinterestArcMenu(
                isOpen: _arcOpen,
                onMaleTap: () {
                  setState(() {
                    _arcOpen = false;
                    _selectedCategory = "male";
                  });
                },
                onFemaleTap: () {
                  setState(() {
                    _arcOpen = false;
                    _selectedCategory = "female";
                  });
                },
                onUnisexTap: () {
                  setState(() {
                    _arcOpen = false;
                    _selectedCategory = "unisex";
                  });
                },
              ),
            ],
          ),

          // ----------------------------------------------------------------------
          // Bottom Navigation Bar
          // ----------------------------------------------------------------------
          bottomNavigationBar: _buildAestheticNavBar(),
        ),
      ),
    );
  }

  // **********************************************************************
  // PREMIUM DRAWER (unchanged, but aesthetic)
  // **********************************************************************
  Widget _buildPremiumDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF6FAF),
                  Color(0xFFB97BFF),
                ],
              ),
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          _drawerItem(Icons.person, "Profile"),
          _drawerItem(Icons.settings, "Settings"),
          _drawerItem(Icons.receipt_long, "Orders"),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, "/login"),
              child: Container(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink.shade400),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {},
    );
  }

  // **********************************************************************
  // PREMIUM GLASS ICON BUTTON
  // **********************************************************************
  Widget _glassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.55),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 22,
        ),
      ),
    );
  }

  // **********************************************************************
  // BOTTOM NAV BAR (unchanged logic)
  // **********************************************************************
  Widget _buildAestheticNavBar() {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  _selectedCategory == "male"
                      ? Icons.male
                      : _selectedCategory == "female"
                          ? Icons.female
                          : _selectedCategory == "unisex"
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

  Widget _navIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = index;
          _arcOpen = false;
        });

        if (index == 0) Navigator.pushNamed(context, "/home");
        if (index == 1) Navigator.pushNamed(context, "/membership");
        if (index == 3) Navigator.pushNamed(context, "/cart");
        if (index == 4) Navigator.pushNamed(context, "/profile");
      },
      child: Icon(
        icon,
        size: 28,
        color: _selected == index ? Colors.pinkAccent : Colors.grey,
      ),
    );
  }
}

// ----------------------------------------------------------------------
// SAME CURVE CLIPPER
// ----------------------------------------------------------------------
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
