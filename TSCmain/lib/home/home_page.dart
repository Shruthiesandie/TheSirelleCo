import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  // ---------------------------
  // NAVIGATION STATE
  // ---------------------------
  int selectedIndex = 0; // 0=Home, 1=Membership, 3=Cart, 4=Profile
  bool arcOpen = false;
  String selectedCategory = "none";

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // ---------------------------
  // CONTROLLERS
  // ---------------------------
  late final PageController heroController;
  late final PageController productController;
  late final ScrollController galleryController;

  @override
  void initState() {
    super.initState();
    heroController = PageController(viewportFraction: 0.92);
    productController = PageController(viewportFraction: 0.72);
    galleryController = ScrollController();
  }

  @override
  void dispose() {
    heroController.dispose();
    productController.dispose();
    galleryController.dispose();
    super.dispose();
  }

  // ---------------------------
  // PAGE SWITCHER
  // ---------------------------
  void switchTab(int index) {
    setState(() {
      selectedIndex = index;
      arcOpen = false;
    });
  }

  // ---------------------------
  // BACK BUTTON BEHAVIOR
  // ---------------------------
  void goBackToHome() {
    setState(() {
      selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFFCEEEE),

          // ---------------------------
          // TOP BAR (depends on tab)
          // ---------------------------
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: selectedIndex == 0
                ? _homeTopBar() // your ORIGINAL curved logo top bar
                : _simpleTopBar(), // back + title
          ),

          // ---------------------------
          // BODY (ALL pages inside IndexedStack)
          // ---------------------------
          body: Stack(
            children: [
              IndexedStack(
                index: selectedIndex == 3 ? 2 : selectedIndex, // mapping
                children: [
                  _homeContent(),

                  _membershipPage(),

                  _cartPage(),

                  _profilePage(),
                ],
              ),

              // ARC MENU stays only on Home
              if (selectedIndex == 0)
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

          // ---------------------------
          // BOTTOM NAV BAR
          // ---------------------------
          bottomNavigationBar: _bottomNavBar(),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BARS
  // ============================================================

  // ------------------- HOME TOP BAR (curved logo bar) -------------------
  Widget _homeTopBar() {
    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.85),
              Colors.white.withOpacity(0.98),
            ],
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
            _glassIconButton(
              Icons.menu,
              () => scaffoldKey.currentState!.openDrawer(),
            ),

            Expanded(
              child: Transform.translate(
                offset: const Offset(20, 0),
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: Image.asset(
                    "assets/logo/logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            Row(
              children: [
                _glassIconButton(Icons.search,
                    () => Navigator.pushNamed(context, "/search")),
                const SizedBox(width: 10),
                _glassIconButton(Icons.favorite_border,
                    () => Navigator.pushNamed(context, "/love")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- SIMPLE PAGE TOP BAR -------------------
  Widget _simpleTopBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: goBackToHome,
      ),
      centerTitle: true,
      title: Text(
        _titleForTab(selectedIndex),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _titleForTab(int index) {
    if (index == 1) return "Membership";
    if (index == 3) return "Cart";
    if (index == 4) return "Profile";
    return "";
  }

  // ============================================================
  // PAGE CONTENTS (INSIDE IndexedStack)
  // ============================================================

  // ------------------- HOME PAGE CONTENT -------------------
  Widget _homeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),

          // HERO SLIDER
          SizedBox(
            height: 240,
            child: PageView.builder(
              controller: heroController,
              itemCount: 4,
              itemBuilder: (_, index) => _heroBanner(index),
            ),
          ),

          const SizedBox(height: 20),

          // POPULAR ITEMS TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Popular Items",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // PRODUCT CAROUSEL
          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: productController,
              itemCount: 6,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: productController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (productController.position.haveDimensions) {
                      value = productController.page! - index;
                      value = (1 - (value.abs() * 0.30)).clamp(0.75, 1.0);
                    }
                    return Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) * 260,
                        width: Curves.easeOut.transform(value) * 200,
                        child: child,
                      ),
                    );
                  },
                  child: _productCard(index),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Gallery",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 130,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              controller: galleryController,
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) => _galleryImage(index),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ------------------- MEMBERSHIP PAGE -------------------
  Widget _membershipPage() {
    return const Center(
      child: Text(
        "Membership Page",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ------------------- CART PAGE -------------------
  Widget _cartPage() {
    return const Center(
      child: Text(
        "Cart Page",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ------------------- PROFILE PAGE -------------------
  Widget _profilePage() {
    return const Center(
      child: Text(
        "Profile Page",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ============================================================
  // DRAWER
  // ============================================================
  Drawer _buildPremiumDrawer() {
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
                  fontSize: 26,
                  color: Colors.white,
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

          // LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 80), () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/login", (route) => false);
                });
              },
              child: Container(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6FAF),
                      Color(0xFFB97BFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
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
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      onTap: () {},
    );
  }

  // ============================================================
  // NAV BAR
  // ============================================================
  Widget _bottomNavBar() {
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

          // CENTER BUTTON (Arc Menu Toggle)
          if (selectedIndex == 0)
            Positioned(
              bottom: 8,
              child: GestureDetector(
                onTap: () => setState(() => arcOpen = !arcOpen),
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
                  ),
                  child: Icon(
                    selectedCategory == "male"
                        ? Icons.male
                        : selectedCategory == "female"
                            ? Icons.female
                            : selectedCategory == "unisex"
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

  Widget _navIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () => switchTab(index),
      child: Icon(
        icon,
        size: 28,
        color: selectedIndex == index
            ? Colors.pinkAccent
            : Colors.grey,
      ),
    );
  }

  // ============================================================
  // SMALL COMPONENTS
  // ============================================================
  Widget _glassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.55),
          border: Border.all(color: Colors.white.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// ============================================================
// CURVED TOP BAR CLIPPER
// ============================================================
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
  bool shouldReclip(_) => false;
}
