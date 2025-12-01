// lib/home/home_page.dart
import 'dart:math';
import 'package:flutter/physics.dart';
import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';
import '../pages/membership_page.dart';

// -------------------------------------------------------------
// HOME PAGE - single-file (3 parts). Paste parts 1 -> 2 -> 3
// -------------------------------------------------------------

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

  // For nav icon spring-tap animation (we use an AnimationController per-tap)
  late final AnimationController _iconSpringController;
  int _animatingIconIndex = -1;

  // For AnimatedSwitcher page transitions we use a small controller to drive a spring simulation
  late final AnimationController _pageSwitchController;

  // For small boolean to prevent multiple fast taps
  bool _pageSwitching = false;

  // For iOS-style left-edge swipe back
  double _dragStartX = 0.0;
  bool _draggingFromEdge = false;

  @override
  void initState() {
    super.initState();
    _heroController = PageController(viewportFraction: 0.92);
    _productController = PageController(viewportFraction: 0.72);
    _galleryController = ScrollController();

    // icon spring controller - small range 0..1
    _iconSpringController = AnimationController.unbounded(vsync: this);

    // page switch controller used only to provide an animation value for transition builder
    _pageSwitchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

    // No need to start anything here.
  }

  @override
  void dispose() {
    _heroController.dispose();
    _productController.dispose();
    _galleryController.dispose();
    _iconSpringController.dispose();
    _pageSwitchController.dispose();
    super.dispose();
  }

  // ----------------------
  // Drag handlers for iOS-back-swipe style
  // ----------------------
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
  // Trigger a physics spring animation for a nav icon tap.
  // We'll animate _iconSpringController from 0->1 using a SpringSimulation and read its value in the widget.
  // ----------------------
  void _playIconSpring(int index) {
    // stop any previous
    _iconSpringController.stop();
    _animatingIconIndex = index;

    // spring parameters tuned for a subtle Apple-like feel
    final spring = SpringDescription(mass: 0.9, stiffness: 360, damping: 28);

    // start value 1.0 to value 0.78 then return to 1.0 using a simulation
    // We'll animate from 0 -> 1 and map that to scale curve inside the builder.
    _iconSpringController.value = 0.0;

    _iconSpringController.animateWith(SpringSimulation(spring, 0.0, 1.0, 0.0)).whenComplete(() {
      // small reset delay then clear animating index
      Future.delayed(const Duration(milliseconds: 60), () {
        if (mounted) setState(() => _animatingIconIndex = -1);
      });
    });
  }

  // ----------------------
  // Page switch using spring - we use the _pageSwitchController to drive the AnimatedSwitcher transitions.
  // We'll still use AnimatedSwitcher but call setState and forward controller with a spring to get a springy timing curve.
  // ----------------------
  Future<void> _switchPage(int index) async {
    if (_pageSwitching || index == selectedIndex) return;
    _pageSwitching = true;

    // Launch a spring for nicer pacing (animation doesn't directly drive AnimatedSwitcher but we'll use its value to shape transitions)
    final spring = SpringDescription(mass: 1.0, stiffness: 200.0, damping: 26.0);
    _pageSwitchController.stop();
    _pageSwitchController.value = 0.0;
    _pageSwitchController.animateWith(SpringSimulation(spring, 0.0, 1.0, 0.0)).whenComplete(() {
      // nothing
    });

    // set new index (AnimatedSwitcher will pick up via key)
    setState(() {
      selectedIndex = index;
      arcOpen = false;
    });

    // ensure at least 300ms before allowing next
    await Future.delayed(const Duration(milliseconds: 320));
    _pageSwitching = false;
  }

  // Convenience combined nav icon tap handler
  void _onNavIconTap(int index) {
    // micro spring visual
    _playIconSpring(index);

    // perform switch
    _switchPage(index);
  }

  // -------------------------------------------------------------
  // TOP BAR BUILDers (home and sub pages)
  // -------------------------------------------------------------
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
            _glassIconButton(Icons.menu, () => _scaffoldKey.currentState?.openDrawer()),
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
            onTap: () => _switchPage(0),
            child: const Icon(Icons.arrow_back_ios, size: 22, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // ----------------------
  // Glass icon button helper
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

  // -------------------------------------------------------------
  // BOTTOM NAV BAR (global) - includes center + always visible
  // -------------------------------------------------------------
  Widget _bottomNavBar() {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3))],
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
                    BoxShadow(color: Colors.pinkAccent.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
                  ],
                ),
                child: Icon(
                  selectedCategory == "male" ? Icons.male : selectedCategory == "female" ? Icons.female : selectedCategory == "unisex" ? Icons.transgender : Icons.add,
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

  // nav icon with micro-spring tap visual using _iconSpringController
  Widget _navIcon(IconData icon, int index) {
    final bool isSelected = selectedIndex == index;

    // scale mapping:
    // when _animatingIconIndex == index, we sample controller value and map it to a subtle overshoot scale curve
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _onNavIconTap(index);
      },
      child: AnimatedBuilder(
        animation: _iconSpringController,
        builder: (context, child) {
          double t = _iconSpringController.value.clamp(0.0, 1.0);
          // mapping function: ease-out then slight overshoot and settle between 1.0 and 0.78
          double scale = 1.0;
          if (_animatingIconIndex == index) {
            // map t [0..1] -> scale path: 1.0 -> 0.78 -> 1.02 -> 1.0
            // simple polynomial mapping:
            if (t < 0.45) {
              scale = 1.0 - 0.28 * (t / 0.45); // down to 0.72-ish
            } else if (t < 0.78) {
              scale = 0.72 + (0.35) * ((t - 0.45) / 0.33); // bump up
            } else {
              scale = 1.02 - 0.02 * ((t - 0.78) / 0.22);
            }
          } else {
            // regular selected state tiny scale 1.02
            scale = isSelected ? 1.02 : 1.0;
          }
          return Transform.scale(
            scale: scale,
            child: Icon(icon, size: 28, color: isSelected ? Colors.pinkAccent : Colors.grey),
          );
        },
      ),
    );
  }
}
// ---------------------- Part 2/3 ----------------------
// Continue inside the same file: home_page.dart
// Home content, hero, carousel, product cards, gallery, and simple placeholder pages

extension _HomeBodyWidgets on _HomePageState {
  // HOME BODY (kept layout same)
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
                        value = ((_productController.page ?? _productController.initialPage) - index).toDouble();
                        value = (1 - (value.abs() * 0.30)).clamp(0.75, 1.0);
                      }
                    } catch (_) {
                      // ignore
                    }
                    final double eased = Curves.easeOut.transform(value);
                    return Center(
                      child: SizedBox(
                        height: eased * 260,
                        width: eased * 200,
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

  // Dummy content pages for membership/cart/profile
  // We keep bottom bar visible and top bar shows back+title.
  Widget _membershipPage() {
    // Use the real MembershipPage widget you already have
    return const MembershipPage();
  }

  Widget _cartPage() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.shopping_cart, size: 48, color: Colors.pink),
        SizedBox(height: 12),
        Text("Cart Page", style: TextStyle(fontSize: 22)),
      ]),
    );
  }

  Widget _profilePage() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.person, size: 48, color: Colors.pink),
        SizedBox(height: 12),
        Text("Profile Page", style: TextStyle(fontSize: 22)),
      ]),
    );
  }

  // Small helpers for repeated UI
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
          child: const Center(
              child: Text("IMAGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22))),
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
}
// ---------------------- Part 3/3 ----------------------
// Continue in same file: additional UI glue, drawer and TopBarClipper

extension _HomeScaffoldBuild on _HomePageState {
  @override
  Widget build(BuildContext context) {
    // Select page content
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
                // AnimatedSwitcher for smooth page change with custom transition using the page switch controller's value
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  transitionBuilder: (child, animation) {
                    // Use animation (0..1) and shape a SlideTransition that slightly springs in.
                    // When switching back to home (selectedIndex == 0) we slide from left, else from right.
                    final fromLeft = selectedIndex == 0;
                    final offset = Tween<Offset>(begin: Offset(fromLeft ? -0.08 : 0.08, 0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOutCubic))
                        .animate(animation);
                    return SlideTransition(position: offset, child: FadeTransition(opacity: animation, child: child));
                  },
                  child: SizedBox(
                    key: ValueKey<int>(selectedIndex),
                    width: double.infinity,
                    height: double.infinity,
                    child: pageContent,
                  ),
                ),

                // Pinterest arc menu (always present) - it relies on your widget implementation
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

  // Drawer (kept same) - logout navigates to /login and removes previous routes
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
}

// TopBarClipper (curved top bar) - unchanged
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
