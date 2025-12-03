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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;
  bool arcOpen = false;

  late final AnimationController _marqueeController;
  late final Animation<double> _marqueeAnimation;

  final List<Widget> screens = const [
    Center(child: Text("Home Page")),
    Center(child: Text("Favourite Page")),
    Center(child: Text("All Categories Page")),
    CartPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    _marqueeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();

    _marqueeAnimation =
        Tween<double>(begin: 1.0, end: -1.0).animate(_marqueeController);
  }

  @override
  void dispose() {
    _marqueeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFCEEEE),
      drawer: _drawer(),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                /// Home page banner and curved top bar
                if (selectedIndex == 0) ...[
                  _marqueeStrip(),
                  _homeTopBar(),
                ],

                /// Back bar for ALL pages except home
                if (selectedIndex != 0) _backOnlyBar(),

                /// Page switching with no destruction
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: screens,
                  ),
                ),
              ],
            ),

            /// Bottom nav anchored
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _bottomNavBar(),
            ),

            /// Floating arc menu
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

  void _setCategory(String _) {
    setState(() => arcOpen = false);
  }

  // ------------------ OFFER STRIP ------------------
  Widget _marqueeStrip() {
    return Container(
      height: 28,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
          const BoxShadow(
            color: Color(0xFFEAEAEA),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: _marqueeAnimation,
        builder: (context, child) {
          return FractionalTranslation(
            translation: Offset(_marqueeAnimation.value, 0),
            child: child,
          );
        },
        child: const Text(
          "  offer available  offer available  offer available  offer available  ",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ------------------ BACK BAR ------------------
  Widget _backOnlyBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () {
              /// Always go back to home
              setState(() {
                selectedIndex = 0;
                arcOpen = false;
              });
            },
          ),
        ],
      ),
    );
  }

  // ------------------ HOME TOP BAR ------------------
  Widget _homeTopBar() {
    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, size: 24),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            ),
            Image.asset(
              "assets/logo/logo.png",
              height: 75,
              width: 75,
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MembershipPage(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ BOTTOM NAV ------------------
  Widget _bottomNavBar() {
    return Container(
      height: 75,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navButton(Icons.home, "Home", 0),
          _navButton(Icons.favorite_border, "favourite", 1),
          _navButton(Icons.grid_view, "All", 2),
          _navButton(Icons.shopping_cart, "cart", 3),
          _navButton(Icons.person, "Profile", 4),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
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
            size: 24,
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

  // ------------------ DRAWER ------------------
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
          ListTile(
            title: const Text("Orders"),
            onTap: () => Navigator.pushNamed(context, "/orders"),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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

// ------------------ CURVED CLIPPER ------------------
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double curve = 25;
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
