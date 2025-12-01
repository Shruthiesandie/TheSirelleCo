// -------------------------------------------------------------
// HOME PAGE - Final Version (Everything inside one file)
// Bottom bar stays globally, top bar is dynamic per page
// -------------------------------------------------------------

import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int selectedIndex = 0;
  bool arcOpen = false;
  String selectedCategory = "none";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  // -------------------------------------------------------------
  // PAGE SWITCHER USING INDEXEDSTACK
  // -------------------------------------------------------------
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

          drawer: _buildPremiumDrawer(),

          // -------------------------------------------------------------
          // DYNAMIC TOP BAR
          // -------------------------------------------------------------
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: selectedIndex == 0
                ? _homeTopBar()        // HOME PAGE TOP BAR (curved)
                : _subPageTopBar(),    // OTHER PAGES SIMPLE TOP BAR
          ),

          // -------------------------------------------------------------
          // PAGE BODY (IndexedStack)
          // -------------------------------------------------------------
          body: Stack(
            children: [
              IndexedStack(
                index: selectedIndex,
                children: [
                  _homePageBody(),        // 0 :: HOME
                  _membershipPage(),      // 1 :: Membership
                  _dummyPage("Cart"),     // 2 :: Cart
                  _dummyPage("Profile"),  // 3 :: Profile
                ],
              ),

              // -------------------------------------------------------------
              // PINTEREST ARC MENU (Now visible on ALL pages)
              // -------------------------------------------------------------
              PinterestArcMenu(
                isOpen: arcOpen,
                onMaleTap: () => _selectCategory("male"),
                onFemaleTap: () => _selectCategory("female"),
                onUnisexTap: () => _selectCategory("unisex"),
              ),
            ],
          ),

          // -------------------------------------------------------------
          // BOTTOM NAVIGATION BAR (Always visible)
          // -------------------------------------------------------------
          bottomNavigationBar: _bottomNavBar(),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // CATEGORY SELECTION (Arc Menu)
  // -------------------------------------------------------------
  void _selectCategory(String category) {
    setState(() {
      arcOpen = false;
      selectedCategory = category;
    });
  }

  // -------------------------------------------------------------
  // TOP BAR: HOME ONLY (Curved + Logo)
  // -------------------------------------------------------------
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
            _glassIconButton(Icons.menu, () => _scaffoldKey.currentState!.openDrawer()),
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
                _glassIconButton(Icons.search, () => Navigator.pushNamed(context, "/search")),
                const SizedBox(width: 10),
                _glassIconButton(Icons.favorite_border, () => Navigator.pushNamed(context, "/love")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TOP BAR: SUB PAGES (Back + Title)
  // -------------------------------------------------------------
  Widget _subPageTopBar() {
    String title = selectedIndex == 1
        ? "Membership"
        : selectedIndex == 2
            ? "Cart"
            : "Profile";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => selectedIndex = 0),
            child: const Icon(Icons.arrow_back_ios, size: 22, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // HOME PAGE BODY
  // -------------------------------------------------------------
  Widget _homePageBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),

          // HERO BANNERS
          SizedBox(
            height: 240,
            child: PageView.builder(
              controller: _heroController,
              itemCount: 4,
              itemBuilder: (_, index) => _heroBanner(index),
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle("Popular Items"),

          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _productController,
              itemCount: 6,
              itemBuilder: (context, index) =>
                  AnimatedBuilder(
                    animation: _productController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_productController.position.haveDimensions) {
                        value = _productController.page! - index;
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
                  ),
            ),
          ),

          const SizedBox(height: 28),

          _sectionTitle("Gallery"),

          SizedBox(
            height: 130,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              controller: _galleryController,
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

  // -------------------------------------------------------------
  // MEMBERSHIP PAGE (placeholder)
  // -------------------------------------------------------------
  Widget _membershipPage() {
    return const Center(
      child: Text("Membership Page", style: TextStyle(fontSize: 22)),
    );
  }

  // -------------------------------------------------------------
  // CART & PROFILE PAGES
  // -------------------------------------------------------------
  Widget _dummyPage(String title) {
    return Center(
      child: Text("$title Page", style: const TextStyle(fontSize: 22)),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE SECTION TITLE
  // -------------------------------------------------------------
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          Text(text,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // HERO BANNER
  // -------------------------------------------------------------
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PRODUCT CARD
  // -------------------------------------------------------------
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
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
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
              Text("Product ${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.pink)),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // GALLERY IMAGE
  // -------------------------------------------------------------
  Widget _galleryImage(int index) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: const Center(
        child: Text("IMAGE", style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // -------------------------------------------------------------
  // GLASS ICON BUTTON
  // -------------------------------------------------------------
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
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
  }

  // -------------------------------------------------------------
  // DRAWER
  // -------------------------------------------------------------
  Drawer _buildPremiumDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text("Menu", style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w700)),
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
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                });
              },
              child: Container(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      onTap: () {},
    );
  }

  // -------------------------------------------------------------
  // BOTTOM NAVIGATION BAR (GLOBAL)
  // -------------------------------------------------------------
  Widget _bottomNavBar() {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3)),
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

          // ALWAYS SHOW + BUTTON IN CENTER
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
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

// -------------------------------------------------------------
// TOP BAR CLIPPER (Curved Home Top Bar)
// -------------------------------------------------------------
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
