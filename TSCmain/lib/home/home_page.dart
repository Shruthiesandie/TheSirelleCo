import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// ------------------------------------------------------------
///     NOTE: THIS FILE NOW HANDLES ALL 4 PAGES INTERNALLY
///     HOME / MEMBERSHIP / CART / PROFILE
///     WITH YOUR EXACT TOP & BOTTOM BAR LOGIC
/// ------------------------------------------------------------
class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  int _selected = 0;
  bool _arcOpen = false;
  String _selectedCategory = "none";

  // Controllers
  late final PageController _heroController;
  late final PageController _productController;
  late final ScrollController _galleryController;

  @override
  void initState() {
    super.initState();
    _heroController = PageController(viewportFraction: 0.92);
    _productController = PageController(viewportFraction: 0.72);
    _galleryController = ScrollController();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _productController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  //   PAGE ROUTER INSIDE THIS FILE (NO EXTERNAL PAGES)
  // ---------------------------------------------------------
  Widget _getPage() {
    if (_selected == 0) return _buildHomePage();
    if (_selected == 1) return _simplePage("Membership");
    if (_selected == 2) return _simplePage("Cart");
    if (_selected == 3) return _simplePage("Profile");
    return _buildHomePage();
  }

  // ---------------------------------------------------------
  //     SIMPLE PAGE WITH BACK + TITLE + BOTTOM BAR
  // ---------------------------------------------------------
  Widget _simplePage(String title) {
    return Column(
      children: [
        // SIMPLE TOP BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 55,
          color: Colors.white,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selected = 0),
                child: const Icon(Icons.arrow_back, size: 26),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        Center(
          child: Text(
            "$title Page",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  //     FULL ORIGINAL HOME PAGE (UNCHANGED DESIGN)
  // ---------------------------------------------------------
  Widget _buildHomePage() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: PageView.builder(
                  controller: _heroController,
                  itemCount: 4,
                  itemBuilder: (_, index) => _heroBanner(index),
                ),
              ),
              const SizedBox(height: 20),

              // POPULAR ITEMS TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: const [
                    Text(
                      "Popular Items",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // PRODUCT CAROUSEL
              SizedBox(
                height: 260,
                child: PageView.builder(
                  controller: _productController,
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _productController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_productController.position.haveDimensions) {
                          value = _productController.page! - index;
                          value =
                              (1 - (value.abs() * 0.30)).clamp(0.75, 1.0);
                        }
                        return Center(
                          child: SizedBox(
                            height: Curves.easeOut.transform(value) *
                                260,
                            width:
                                Curves.easeOut.transform(value) * 200,
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

              // GALLERY TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: const [
                    Text(
                      "Gallery",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // GALLERY HORIZONTAL LIST
              SizedBox(
                height: 130,
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18),
                  controller: _galleryController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                  itemBuilder: (_, index) =>
                      _galleryImage(index),
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),

        // ARC MENU
        PinterestArcMenu(
          isOpen: _arcOpen,
          onMaleTap: () => setState(() {
            _arcOpen = false;
            _selectedCategory = "male";
          }),
          onFemaleTap: () => setState(() {
            _arcOpen = false;
            _selectedCategory = "female";
          }),
          onUnisexTap: () => setState(() {
            _arcOpen = false;
            _selectedCategory = "unisex";
          }),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  //                      MAIN BUILD
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFFCEEEE),

          // TOP BAR ONLY ON HOME
          appBar: _selected == 0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(90),
                  child: ClipPath(
                    clipper: TopBarClipper(),
                    child: _homeTopBar(),
                  ),
                )
              : null,

          drawer: _selected == 0 ? _buildPremiumDrawer() : null,

          body: _getPage(),

          bottomNavigationBar: _bottomNavBar(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // HOME TOP BAR (your original)
  // ---------------------------------------------------------
  Widget _homeTopBar() {
    return Container(
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
            () => _scaffoldKey.currentState!.openDrawer(),
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
    );
  }

  // ---------------------------------------------------------
  // BOTTOM NAVIGATION (Home + Membership + Cart + Profile)
  // ---------------------------------------------------------
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(Icons.home_filled, 0),
          _navIcon(Icons.card_membership, 1),
          _navIcon(Icons.shopping_cart, 2),
          _navIcon(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () => setState(() {
        _selected = index;
        _arcOpen = false;
      }),
      child: Icon(
        icon,
        size: 28,
        color: _selected == index
            ? Colors.pinkAccent
            : Colors.grey,
      ),
    );
  }

  // ---------------------------------------------------------
  // UI COMPONENTS (same as your older version)
  // ---------------------------------------------------------
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
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink.shade400),
      title: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16)),
      onTap: () {},
    );
  }

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
                colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
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

          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/login", (route) => false);
                });
              },
              child: Container(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Logout",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _heroBanner(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.pink.shade100],
            ),
          ),
          child: const Center(
            child: Text(
              "IMAGE",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _productCard(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text("IMAGE"),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Product ${index + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _galleryImage(int index) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: const Center(
        child: Text(
          "IMAGE",
          style: TextStyle(
            color: Colors.pink,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// CURVE CLIPPER (UNCHANGED)
// ------------------------------------------------------
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const curveHeight = 24;
    return Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(size.width / 2, size.height + curveHeight,
          size.width, size.height - curveHeight)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}
