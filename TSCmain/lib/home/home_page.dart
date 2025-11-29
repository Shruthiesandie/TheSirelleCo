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

          drawer: _softBlobDrawer(),

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
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              "assets/logo/logo.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        _roundAction(Icons.search, "/search"),
                        const SizedBox(width: 6),
                        _roundAction(Icons.favorite_border, "/love"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

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

          bottomNavigationBar: _navBar(),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // ⭐ OPTION F — AESTHETIC SOFT-BLOB DRAWER
  // -------------------------------------------------------------------
  Widget _softBlobDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          // BIG aesthetic background blobs
          Positioned(
            left: -80,
            top: -40,
            child: _blob(200, Colors.pinkAccent.withOpacity(0.22)),
          ),
          Positioned(
            right: -50,
            top: 140,
            child: _blob(160, Colors.purpleAccent.withOpacity(0.20)),
          ),
          Positioned(
            left: -40,
            bottom: -20,
            child: _blob(140, Colors.pink.withOpacity(0.18)),
          ),

          Column(
            children: [
              const SizedBox(height: 140),

              // HEADER TEXT
              const Padding(
                padding: EdgeInsets.only(left: 26),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // OPTIONS
              _drawerButton(Icons.person, "Profile"),
              _drawerButton(Icons.settings, "Settings"),
              _drawerButton(Icons.receipt_long, "Orders"),

              const Spacer(),

              // LOGOUT BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, "/login"),
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white, size: 20),
                        SizedBox(width: 7),
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
          )
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _drawerButton(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {},
    );
  }

  // -------------------------------------------------------------------
  // MODERN ACTION ICONS
  // -------------------------------------------------------------------
  Widget _roundAction(IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.black),
      ),
    );
  }

  // -------------------------------------------------------------------
  // MODERN NAV BAR (unchanged layout)
  // -------------------------------------------------------------------
  Widget _navBar() {
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
              _navItem(Icons.home_filled, 0),
              _navItem(Icons.card_membership, 1),
              const SizedBox(width: 60),
              _navItem(Icons.shopping_cart, 3),
              _navItem(Icons.person, 4),
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
                    colors: [
                      Color(0xFFFF6FAF),
                      Color(0xFFB97BFF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    )
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
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
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

class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const curveHeight = 24;

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
