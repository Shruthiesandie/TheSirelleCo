import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  bool arcOpen = false;
  String selectedCategory = "none";

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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

  // SWITCH TABS
  void switchTab(int index) {
    setState(() {
      selectedIndex = index;
      arcOpen = false;
    });
  }

  void goBackToHome() {
    setState(() => selectedIndex = 0);
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

          // TOP BAR
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: selectedIndex == 0
                ? _homeTopBar()
                : _simpleTopBar(),
          ),

          // BODY
          body: Stack(
            children: [
              IndexedStack(
                index: selectedIndex,
                children: [
                  _homeContent(),
                  _membershipPage(),
                  _cartPage(),
                  _profilePage(),
                ],
              ),

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

          bottomNavigationBar: _bottomNavBar(),
        ),
      ),
    );
  }

  // ---------------------------
  // HOME TOP BAR
  // ---------------------------
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

  // ---------------------------
  // SIMPLE PAGE TOP BAR
  // ---------------------------
  Widget _simpleTopBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: goBackToHome,
      ),
      title: Text(
        _titleForTab(selectedIndex),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  String _titleForTab(int index) {
    if (index == 1) return "Membership";
    if (index == 2) return "Cart";
    if (index == 3) return "Profile";
    return "";
  }

  // ---------------------------
  // HOME CONTENT
  // ---------------------------
  Widget _homeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),

          SizedBox(
            height: 240,
            child: PageView.builder(
              controller: heroController,
              itemCount: 4,
              itemBuilder: (_, index) => _heroBanner(index),
            ),
          ),

          const SizedBox(height: 20),

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
                      value =
                          (1 - (value.abs() * 0.30)).clamp(0.75, 1.0);
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

  // ---------------------------
  // OTHER PAGES
  // ---------------------------
  Widget _membershipPage() => const Center(child: Text("Membership Page"));
  Widget _cartPage() => const Center(child: Text("Cart Page"));
  Widget _profilePage() => const Center(child: Text("Profile Page"));

  // ---------------------------
  // HERO BANNER (RESTORED)
  // ---------------------------
  Widget _heroBanner(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pink.shade200,
                Colors.pink.shade100,
              ],
            ),
          ),
          child: Center(
            child: Text(
              "IMAGE ${index + 1}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------
  // PRODUCT CARD (RESTORED)
  // ---------------------------
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
                offset: const Offset(0, 4),
              ),
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
                  child: const Center(child: Text("IMAGE")),
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

  // ---------------------------
  // GALLERY IMAGE (RESTORED)
  // ---------------------------
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "IMAGE ${index + 1}",
          style: const TextStyle(
            color: Colors.pink,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ---------------------------
  // GLASS ICON BUTTON
  // ---------------------------
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

  // ---------------------------
  // DRAWER
  // ---------------------------
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
          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
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

  // ---------------------------
  // BOTTOM NAV BAR
  // ---------------------------
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
              _navIcon(Icons.shopping_cart, 2),
              _navIcon(Icons.person, 3),
            ],
          ),

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
        color:
            selectedIndex == index ? Colors.pinkAccent : Colors.grey,
      ),
    );
  }
}

// ---------------------------
// CURVED CLIPPER
// ---------------------------
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
