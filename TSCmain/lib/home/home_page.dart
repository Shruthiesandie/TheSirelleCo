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

  // ⭐ NEW — store selected category for plus icon
  String _selectedCategory = "none";  
  // values: none, male, female, unisex

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

          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: ClipPath(
              clipper: TopBarClipper(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white,
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
                          child: Container(
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
                        IconButton(
                          icon: const Icon(Icons.search,
                              size: 26, color: Colors.black),
                          onPressed: () =>
                              Navigator.pushNamed(context, "/search"),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border,
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

          body: Stack(
            children: [
              const Center(
                child: Text(
                  "Home Page",
                  style: TextStyle(fontSize: 22, color: Colors.black87),
                ),
              ),

              // ⭐ UPDATE arc menu taps to change selected category
              PinterestArcMenu(
                isOpen: _arcOpen,
                onMaleTap: () {
                  setState(() {
                    _arcOpen = false;
                    _selectedCategory = "male"; // ⭐ NEW
                  });
                },
                onFemaleTap: () {
                  setState(() {
                    _arcOpen = false;
                    _selectedCategory = "female"; // ⭐ NEW
                  });
                },
                onUnisexTap: () {
                  setState(() {
                    _arcOpen = false;
                    _selectedCategory = "unisex"; // ⭐ NEW
                  });
                },
              ),
            ],
          ),

          bottomNavigationBar: _buildAestheticNavBar(),
        ),
      ),
    );
  }

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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                // ⭐ DYNAMIC ICON BASED ON SELECTED CATEGORY
                child: Icon(
                  _selectedCategory == "male"
                      ? Icons.male
                      : _selectedCategory == "female"
                          ? Icons.female
                          : _selectedCategory == "unisex"
                              ? Icons.transgender   // ⚥ unisex symbol
                              : Icons.add,          // default plus
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
