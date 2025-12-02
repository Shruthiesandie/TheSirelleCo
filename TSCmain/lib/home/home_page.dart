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

  final List<String> pages = ["Home", "Favourite", "All", "Cart", "Profile"];

  final List<Widget> screens = const [
    Center(child: Text("Home Page")),
    MembershipPage(),
    Center(child: Text("All Categories Page")),
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
                _marqueeStrip(),
                _buildTopBar(),
                Expanded(child: screens[selectedIndex]),
                _bottomNavBar(),
              ],
            ),

            PinterestArcMenu(
              isOpen: arcOpen,
              onMaleTap: () => _setCategory("male"),
              onFemaleTap: () => _setCategory("female"),
              onUnisexTap: () => _setCategory("unisex"),
            ),
          ],
        ),
      ),
    );
  }

  void _setCategory(String type) {
    setState(() {
      arcOpen = false;
      selectedCategory = type;
    });
  }

  // ---------------------------------------------------------
  // SEPARATE OFFER STRIP WITH MOVING TEXT
  // ---------------------------------------------------------
  Widget _marqueeStrip() {
    return Container(
      height: 22,
      width: double.infinity,
      color: Colors.white,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: Listenable.merge([ValueNotifier(0)]),
          builder: (context, _) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: -1),
              duration: const Duration(seconds: 8),
              repeat: true,
              builder: (context, value, _) {
                return FractionalTranslation(
                  translation: Offset(value, 0),
                  child: const Text(
                    "offer available   offer available   offer available   offer available   ",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // TOP BAR LOGIC
  // ---------------------------------------------------------
  Widget _buildTopBar() {
    if (selectedIndex == 0) {
      return ClipPath(
        clipper: TopBarClipper(),
        child: Container(
          height: 95,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, size: 22, color: Colors.black),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              ),
              Image.asset(
                "assets/logo/logo.png",
                height: 58,
                width: 58,
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
                  ),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return Container(
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, size: 22),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            ),
            Text(
              pages[selectedIndex],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 40),
          ],
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // PERFECT BOTTOM BAR — FLUSH DOWN, CURVED CORNERS
  // ---------------------------------------------------------
  Widget _bottomNavBar() {
    return Container(
      height: 64,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
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
            size: 22,
            color: selectedIndex == index
                ? Colors.pinkAccent
                : Colors.grey.shade500,
          ),
          const SizedBox(height: 3),
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

  // ---------------------------------------------------------
  // DRAWER (WITH LOGOUT INCLUDED)
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

// ---------------------------------------------------------
// CURVED CLIPPER FOR HOME TOP BAR
// ---------------------------------------------------------
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double curve = 30;

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
