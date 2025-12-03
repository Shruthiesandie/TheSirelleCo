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

  final List<String> pages = ["Home", "Favourite", "All", "Cart", "Profile"];

  final List<Widget> screens = const [
    Center(child: Text("Home Page")),
    MembershipPage(),
    Center(child: Text("All Categories Page")),
    CartPage(),
    ProfilePage(),
  ];

  // ============================================================
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
                _marqueeStrip(),  // continuous scroller
                _titleBar(),      // dynamic app bar
                Expanded(child: screens[selectedIndex]),
              ],
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _bottomNavBar(),  // perfectly stuck to bottom
            ),

            PinterestArcMenu(
              isOpen: arcOpen,
              onMaleTap: () => _selectCategory("male"),
              onFemaleTap: () => _selectCategory("female"),
              onUnisexTap: () => _selectCategory("unisex"),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCategory(String type) {
    setState(() {
      arcOpen = false;
    });
  }

  // ============================================================
  // TOP OFFER STRIP — CONTINUOUS AUTO SCROLL
  Widget _marqueeStrip() {
    return Container(
      height: 26,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
        color: Colors.white,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: -1),
        duration: const Duration(seconds: 6),
        onEnd: () => setState(() {}), // restart animation -> infinite loop
        builder: (context, value, _) {
          return FractionalTranslation(
            translation: Offset(value, 0),
            child: const Text(
              "  offer available  offer available  offer available  offer available  ",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // TOP BAR — HOME = Logo + Curve, Other = Back + Title
  Widget _titleBar() {
    if (selectedIndex == 0) {
      // HOME SCREEN BAR
      return ClipPath(
        clipper: TopBarClipper(),
        child: Container(
          height: 90,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, size: 24),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              ),

              Image.asset(
                "assets/logo/logo.png",
                height: 55,
                width: 55,
                fit: BoxFit.contain,
              ),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, size: 22),
                    onPressed: () => Navigator.pushNamed(context, "/search"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.workspace_premium, size: 22),
                    onPressed: () => Navigator.pushNamed(context, "/membership"),
                  )
                ],
              )
            ],
          ),
        ),
      );
    } else {
      // OTHER PAGE TOP BAR — SIMPLE + BACK + TITLE
      return Container(
        height: 50,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              onPressed: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
            ),
            Text(
              pages[selectedIndex],
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  // ============================================================
  // PERFECT BOTTOM BAR — ALWAYS AT BOTTOM, CURVED TOP
  Widget _bottomNavBar() {
    return Container(
      height: 64,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.home, "Home", 0),
          _navIcon(Icons.favorite_border, "favourite", 1),
          _navIcon(Icons.grid_view, "All", 2),
          _navIcon(Icons.shopping_cart, "cart", 3),
          _navIcon(Icons.person, "Profile", 4),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 22,
              color: selectedIndex == index
                  ? Colors.pinkAccent
                  : Colors.grey.shade500),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: selectedIndex == index
                  ? Colors.pinkAccent
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DRAWER + LOGOUT
  Drawer _drawer() {
    return Drawer(
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
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
          ListTile(
            title: const Text("Orders"),
            onTap: () => Navigator.pushNamed(context, "/orders"),
          ),
          const Divider(),
          ListTile(
            title: const Text("Logout",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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

// ============================================================
// CURVE SHAPE FOR HOME BAR
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double curve = 25;

    return Path()
      ..lineTo(0, size.height - curve)
      ..quadraticBezierTo(
          size.width / 2, size.height + curve, size.width, size.height - curve)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
