// home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // page controller for full horizontal swipe
  late final PageController _pageController;

  // product/hero/gallery controllers (kept from your previous file)
  late final PageController _heroController;
  late final PageController _productController;
  late final ScrollController _galleryController;

  // UI state
  int selectedIndex = 0; // tracks the active page index (0: Home,1:Membership,2:Cart,3:Profile)
  bool arcOpen = false;
  String selectedCategory = "none";

  // small animation controller to provide a springy icon tap feedback
  late final AnimationController _iconTapController;
  late final Animation<double> _iconTapAnim;

  // scaffold key for drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Spring tuning (tweak here if you want a firmer/looser spring)
  final SpringDescription _scrollSpring = const SpringDescription(
    mass: 0.8, // mass
    stiffness: 220.0, // stiffness (higher -> faster)
    damping: 22.0, // damping (higher -> less bounce)
  );

  @override
  void initState() {
    super.initState();
    // main page controller with initial page = selectedIndex
    _pageController = PageController(initialPage: selectedIndex);

    // keep your other controllers for carousels
    _heroController = PageController(viewportFraction: 0.92);
    _productController = PageController(viewportFraction: 0.72);
    _galleryController = ScrollController();

    // small scale animation for icon tap feedback
    _iconTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    // Using CurvedAnimation for a spring-like feel (non-overshooting)
    _iconTapAnim = CurvedAnimation(parent: _iconTapController, curve: Curves.easeOutCubic);

    // Listen page controller to update selectedIndex when user swipes manually
    _pageController.addListener(_pageListener);
  }

  void _pageListener() {
    // Round the page value to nearest index, but only update when close to integer to avoid setState thrash
    final p = _pageController.hasClients ? _pageController.page ?? _pageController.initialPage.toDouble() : selectedIndex.toDouble();
    final round = p.round();
    if (round != selectedIndex && (p - round).abs() < 0.15) {
      setState(() => selectedIndex = round);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    _heroController.dispose();
    _productController.dispose();
    _galleryController.dispose();
    _iconTapController.dispose();
    super.dispose();
  }

  // ---------------------------
  // Helper: physics spring scroll to target page index
  // Uses ScrollPosition.animateWith(SpringSimulation) for UIKit-like spring
  // ---------------------------
  Future<void> _animateToPageWithSpring(int page) async {
    if (!_pageController.hasClients) {
      // fallback
      await _pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
      return;
    }

    final position = _pageController.position;
    final viewportDimension = position.viewportDimension;
    final currentPixels = position.pixels;
    final targetPixels = page * viewportDimension;

    // If already at target (or nearly), just set state and return
    if ((currentPixels - targetPixels).abs() < 0.5) {
      setState(() => selectedIndex = page);
      return;
    }

    // initial velocity: convert pageController's velocity? We don't have direct velocity; use 0 for safe behavior
    final double initialVelocity = 0.0;

    // Create simulation
    final sim = SpringSimulation(_scrollSpring, currentPixels, targetPixels, initialVelocity);

    // Animate scroll using position.animateWith(sim)
    try {
      // start small icon tap visual
      _iconTapController
        ..stop()
        ..value = 0.0
        ..forward();

      await position.animateWith(sim);
      // ensure pageController settles to exact page
      await _pageController.animateToPage(page, duration: const Duration(milliseconds: 60), curve: Curves.easeOutCubic);
    } catch (_) {
      // fallback safe animate
      await _pageController.animateToPage(page, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
    } finally {
      // finalize states
      setState(() => selectedIndex = page);
      // reverse tap animation gently
      if (_iconTapController.status == AnimationStatus.completed) {
        _iconTapController.reverse();
      }
    }
  }

  // ---------------------------
  // Main build
  // ---------------------------
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

          // Dynamic top bar: Home uses curved top bar with logo, other pages use simple back + title
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: selectedIndex == 0 ? _homeTopBar() : _subPageTopBar(),
          ),

          // Body: PageView that allows full horizontal swipe
          body: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const PageScrollPhysics(), // standard paging behavior; works well with full-swipe
                onPageChanged: (idx) => setState(() => selectedIndex = idx),
                children: [
                  _homePageBody(),
                  _membershipPage(),
                  _cartPage(),
                  _profilePage(),
                ],
              ),

              // Ensure PinterestArcMenu is visible on all pages and centered as before
              PinterestArcMenu(
                isOpen: arcOpen,
                onMaleTap: () => _selectCategory("male"),
                onFemaleTap: () => _selectCategory("female"),
                onUnisexTap: () => _selectCategory("unisex"),
              ),
            ],
          ),

          // Bottom nav: always visible; taps trigger physics-spring scroll
          bottomNavigationBar: _bottomNavBar(),
        ),
      ),
    );
  }

  // ---------------------------
  // Top bars
  // ---------------------------
  Widget _homeTopBar() {
    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.85), Colors.white.withOpacity(0.98)],
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 2))],
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
                  child: Image.asset("assets/logo/logo.png", fit: BoxFit.contain),
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

  Widget _subPageTopBar() {
    String title = selectedIndex == 1 ? "Membership" : selectedIndex == 2 ? "Cart" : "Profile";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              // If already on home, do nothing; else animate back to home with spring
              if (selectedIndex != 0) await _animateToPageWithSpring(0);
            },
            child: const Icon(Icons.arrow_back_ios, size: 22, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // ---------------------------
  // Page bodies (kept same look as original)
  // ---------------------------
  Widget _homePageBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: PageView.builder(controller: _heroController, itemCount: 4, itemBuilder: (_, index) => _heroBanner(index)),
          ),
          const SizedBox(height: 20),
          _sectionTitle("Popular Items"),
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
                      value = (_productController.page ?? _productController.initialPage.toDouble()) - index;
                      value = (1 - (value.abs() * 0.30)).clamp(0.75, 1.0);
                    }
                    return Center(
                      child: SizedBox(height: Curves.easeOut.transform(value) * 260, width: Curves.easeOut.transform(value) * 200, child: child),
                    );
                  },
                  child: _productCard(index),
                );
              },
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

  Widget _membershipPage() {
    // Keep membership content minimal — user asked earlier to keep logic unchanged
    return const Center(child: Text("Membership Page", style: TextStyle(fontSize: 22)));
  }

  Widget _cartPage() {
    return const Center(child: Text("Cart Page", style: TextStyle(fontSize: 22)));
  }

  Widget _profilePage() {
    return const Center(child: Text("Profile Page", style: TextStyle(fontSize: 22)));
  }

  // ---------------------------
  // Small reusable widgets from your file
  // ---------------------------
  Widget _heroBanner(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.pink.shade200, Colors.pink.shade100])),
          child: const Center(child: Text("IMAGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22))),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(
            children: [
              Expanded(
                child: Container(decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(16)), child: const Center(child: Text("IMAGE"))),
              ),
              const SizedBox(height: 10),
              Text("Product ${index + 1}", style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.pink)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _galleryImage(int index) {
    return Container(
      width: 120,
      decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))]),
      child: const Center(child: Text("IMAGE", style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w600))),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(children: [Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))]),
    );
  }

  Widget _glassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.55), border: Border.all(color: Colors.white.withOpacity(0.8)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))]),
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
  }

  // ---------------------------
  // Drawer & drawer items (kept same)
  // ---------------------------
  Drawer _buildPremiumDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)])),
            child: const Align(alignment: Alignment.bottomLeft, child: Text("Menu", style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w700))),
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
                // close drawer then navigate to login removing previous routes
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                });
              },
              child: Container(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]), borderRadius: BorderRadius.circular(14)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout, color: Colors.white), SizedBox(width: 8), Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label) {
    return ListTile(leading: Icon(icon, color: Colors.pink.shade400), title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)), onTap: () {});
  }

  // ---------------------------
  // Bottom nav & center + button
  // ---------------------------
  Widget _bottomNavBar() {
    return Container(
      height: 74,
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3))]),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _navIcon(Icons.home_filled, 0),
            _navIcon(Icons.card_membership, 1),
            const SizedBox(width: 60),
            _navIcon(Icons.shopping_cart, 2),
            _navIcon(Icons.person, 3),
          ]),
          // Always show + button in center
          Positioned(
            bottom: 8,
            child: GestureDetector(
              onTap: () => setState(() => arcOpen = !arcOpen),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]), boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))]),
                child: Icon(selectedCategory == "male" ? Icons.male : selectedCategory == "female" ? Icons.female : selectedCategory == "unisex" ? Icons.transgender : Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        // Tap feedback via small scale animation
        _iconTapController
          ..stop()
          ..value = 0.0
          ..forward();

        // Trigger physics spring page change
        _animateToPageWithSpring(index);
      },
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.86).animate(_iconTapAnim),
        child: Icon(icon, size: 28, color: isSelected ? Colors.pinkAccent : Colors.grey),
      ),
    );
  }

  // Category selection handler
  void _selectCategory(String cat) {
    setState(() {
      arcOpen = false;
      selectedCategory = cat;
    });
  }
}

// -------------------------------------------------------------
// Top bar clipper (unchanged)
// -------------------------------------------------------------
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const curveHeight = 24;
    return Path()..lineTo(0, size.height - curveHeight)..quadraticBezierTo(size.width / 2, size.height + curveHeight, size.width, size.height - curveHeight)..lineTo(size.width, 0)..close();
  }

  @override
  bool shouldReclip(_) => false;
}
