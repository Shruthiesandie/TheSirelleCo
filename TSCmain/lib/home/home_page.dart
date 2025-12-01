// lib/home/home_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Main navigation state
  int selectedIndex = 0; // 0: Home, 1: Membership, 2: Cart, 3: Profile
  bool arcOpen = false;
  String selectedCategory = "none";

  // Scaffold key for drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Home inner controllers
  late final PageController _heroController;
  late final PageController _productController;
  late final ScrollController _galleryController;

  // For nav icon tap animation
  int _lastTappedIcon = -1;

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

  // ----------------------
  // Helper: simulated spring-scoped animation for PageView -> used inside product carousel (no external API)
  // We'll use AnimatedBuilder previously - kept in product carousel code below (no extra method needed).
  // ----------------------

  // ----------------------
  // iOS-like left-edge swipe: if user is on non-home screen, swiping right from left edge returns to home.
  // We'll capture horizontal drag gestures at top-level stack.
  // ----------------------
  double _dragStartX = 0.0;
  bool _draggingFromEdge = false;

  void _handleHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _draggingFromEdge = _dragStartX < 32 && selectedIndex != 0;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_draggingFromEdge) return;
    final delta = details.delta.dx;
    // if user drags enough to right, go back
    if (delta > 12) {
      setState(() {
        selectedIndex = 0;
        arcOpen = false;
      });
      _draggingFromEdge = false;
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    _dragStartX = 0.0;
    _draggingFromEdge = false;
  }

  // ----------------------
  // Animate small "spring" tap effect on bottom icons.
  // We simulate a spring feel by briefly setting _lastTappedIcon and using TweenAnimationBuilder for scale.
  // ----------------------
  void _onNavIconTap(int index) {
    // When icon tapped, animate micro scale and switch page
    setState(() {
      _lastTappedIcon = index;
      selectedIndex = index;
      arcOpen = false;
    });

    // reset tap indicator after short time (so TweenAnimationBuilder returns to scale = 1)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _lastTappedIcon = -1);
    });
  }

  // ----------------------
  // Bottom nav bar
  // ----------------------
  Widget _bottomNavBar() {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26), topRight: Radius.circular(26)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // main row icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navIcon(Icons.home_filled, 0),
              _navIcon(Icons.card_membership, 1),
              const SizedBox(width: 60), // gap for center + button
              _navIcon(Icons.shopping_cart, 2),
              _navIcon(Icons.person, 3),
            ],
          ),

          // center + button (always visible)
          Positioned(
            bottom: 8,
            child: GestureDetector(
              onTap: () => setState(() => arcOpen = !arcOpen),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
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

  // nav icon with micro-spring tap
  Widget _navIcon(IconData icon, int index) {
    final bool isSelected = selectedIndex == index;
    final bool wasTapped = _lastTappedIcon == index;

    // scale: when tapped -> small overshoot bounce using TweenAnimationBuilder + curve
    final double targetScale = wasTapped ? 0.78 : (isSelected ? 1.02 : 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onNavIconTap(index),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 420),
        curve: const Cubic(0.22, 1.2, 0.38, 1.0), // nice springy-ish easing
        tween: Tween<double>(begin: 1.0, end: targetScale),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Icon(icon, size: 28, color: isSelected ? Colors.pinkAccent : Colors.grey),
          );
        },
      ),
    );
  }

  // ----------------------
  // TOP BAR: home (curved with logo)
  // ----------------------
  Widget _homeTopBar() {
    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.85), Colors.white.withOpacity(0.98)],
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 2)),
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
                  child: Image.asset("assets/logo/logo.png", fit: BoxFit.contain),
                ),
              ),
            ),
            Row(children: [
              _glassIconButton(Icons.search, () => Navigator.pushNamed(context, "/search")),
              const SizedBox(width: 10),
              _glassIconButton(Icons.favorite_border, () => Navigator.pushNamed(context, "/love")),
            ]),
          ],
        ),
      ),
    );
  }

  // ----------------------
  // TOP BAR: sub-pages (simple back + title)
  // ----------------------
  Widget _subPageTopBar() {
    String title;
    switch (selectedIndex) {
      case 1:
        title = "Membership";
        break;
      case 2:
        title = "Cart";
        break;
      case 3:
        title = "Profile";
        break;
      default:
        title = "";
    }

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

  // ----------------------
  // GLASS ICON BUTTON (kept same)
  // ----------------------
  Widget _glassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.55),
          border: Border.all(color: Colors.white.withOpacity(0.8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
  }

  // ----------------------
  // Drawer (kept same) - logout navigates to /login and removes previous routes
  // ----------------------
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
                // close drawer first then navigate
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 120), () {
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

  // ----------------------
  // HOME BODY (kept layout same) - extracted to a widget
  // ----------------------
  Widget _homeBody() {
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

          // PRODUCT CAROUSEL with simulated 3D scale effect (kept same)
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
                    try {
                      if (_productController.position.haveDimensions) {
                        value = _productController.page! - index;
                        value = (1 - (value.abs() * 0.30)).clamp(0.75, 1.0);
                      }
                    } catch (_) {
                      // in older flutter versions accessing .page may throw when not yet attached -
                      // we ignore errors and keep default scale.
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

  // ----------------------
  // Dummy content pages for membership/cart/profile
  // We keep bottom bar visible and top bar shows back+title.
  // ----------------------
  Widget _membershipPage() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.card_membership, size: 48, color: Colors.pink),
          SizedBox(height: 12),
          Text("Membership Page", style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }

  Widget _cartPage() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [
      Icon(Icons.shopping_cart, size: 48, color: Colors.pink),
      SizedBox(height: 12),
      Text("Cart Page", style: TextStyle(fontSize: 22)),
    ]));
  }

  Widget _profilePage() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [
      Icon(Icons.person, size: 48, color: Colors.pink),
      SizedBox(height: 12),
      Text("Profile Page", style: TextStyle(fontSize: 22)),
    ]));
  }

  // ----------------------
  // Small helpers for repeated UI
  // ----------------------
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(children: [
        Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))
      ]),
    );
  }

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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
          ]),
          child: Column(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text("IMAGE")),
              ),
            ),
            const SizedBox(height: 10),
            Text("Product ${index + 1}", style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.pink)),
          ]),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: const Center(child: Text("IMAGE", style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w600))),
    );
  }

  // ----------------------
  // Build
  // ----------------------
  @override
  Widget build(BuildContext context) {
    // AnimatedSwitcher wraps the "page area" (top bar handled separately with PreferredSize)
    Widget pageContent;
    switch (selectedIndex) {
      case 0:
        pageContent = _homeBody();
        break;
      case 1:
        pageContent = _membershipPage();
        break;
      case 2:
        pageContent = _cartPage();
        break;
      case 3:
        pageContent = _profilePage();
        break;
      default:
        pageContent = _homeBody();
    }

    // top bar widget selection
    final PreferredSizeWidget topBar = PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: selectedIndex == 0 ? _homeTopBar() : _subPageTopBar(),
    );

    return GestureDetector(
      onHorizontalDragStart: _handleHorizontalDragStart,
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xFFFCEEEE),
            drawer: _buildPremiumDrawer(),
            appBar: topBar,
            body: Stack(
              children: [
                // AnimatedSwitcher for smooth page change
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  transitionBuilder: (child, animation) {
                    // slide from right when switching to non-home, from left when returning
                    final inFromLeft = selectedIndex == 0;
                    final offsetTween = Tween<Offset>(
                      begin: Offset(inFromLeft ? -0.08 : 0.08, 0),
                      end: Offset.zero,
                    );
                    return SlideTransition(position: animation.drive(offsetTween), child: FadeTransition(opacity: animation, child: child));
                  },
                  child: SizedBox(
                    // key required for AnimatedSwitcher to detect different children
                    key: ValueKey<int>(selectedIndex),
                    width: double.infinity,
                    height: double.infinity,
                    child: pageContent,
                  ),
                ),

                // Pinterest arc menu (always present)
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
      ),
    );
  }
}

// ----------------------------
// TopBarClipper (curved top bar) - unchanged
// ----------------------------
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const curveHeight = 24;
    return Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(size.width / 2, size.height + curveHeight, size.width, size.height - curveHeight)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}
