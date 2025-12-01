
import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';
import '../pages/membership_page.dart';

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

  int _lastTappedIcon = -1;
  double _dragStartX = 0.0;
  bool _draggingFromEdge = false;

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

  // ---------------------
  // iOS Back Swipe
  // ---------------------
  void _handleHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _draggingFromEdge = _dragStartX < 32 && selectedIndex != 0;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_draggingFromEdge) return;
    if (details.delta.dx > 12) {
      setState(() {
        selectedIndex = 0;
        arcOpen = false;
      });
      _draggingFromEdge = false;
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    _draggingFromEdge = false;
    _dragStartX = 0;
  }

  // ---------------------
  // Bottom Nav Tap
  // ---------------------
  void _onNavIconTap(int index) {
    setState(() {
      _lastTappedIcon = index;
      selectedIndex = index;
      arcOpen = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _lastTappedIcon = -1);
    });
  }

  // ---------------------
  // Bottom Nav Bar
  // ---------------------
  Widget _bottomNavBar() {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
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

  Widget _navIcon(IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    bool wasTapped = _lastTappedIcon == index;

    double targetScale = wasTapped ? 0.78 : (isSelected ? 1.1 : 1.0);

    return GestureDetector(
      onTap: () => _onNavIconTap(index),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 420),
        curve: const Cubic(0.22, 1.2, 0.38, 1.0),
        tween: Tween(begin: 1.0, end: targetScale),
        builder: (_, scale, child) => Transform.scale(
          scale: scale,
          child: Icon(icon, size: 28, color: isSelected ? Colors.pinkAccent : Colors.grey),
        ),
      ),
    );
  }

  // ---------------------
  // Home Top Bar
  // ---------------------
  Widget _homeTopBar() {
    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.85),
              Colors.white.withOpacity(0.98)
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 2),
            )
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
            )
          ],
        ),
      ),
    );
  }

  // ---------------------
  // Subpage Top Bar
  // ---------------------
  Widget _subPageTopBar() {
    final titles = ["Home", "Membership", "Cart", "Profile"];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => selectedIndex = 0),
            child: const Icon(Icons.arrow_back_ios, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            titles[selectedIndex],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ---------------------
  // Glass button widget
  // ---------------------
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
            )
          ],
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }

  // ---------------------
  // Drawer
  // ---------------------
  Drawer _buildPremiumDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
            ),
            child: const Text(
              "Menu",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),

          _drawerItem(Icons.person, "Profile"),
          _drawerItem(Icons.settings, "Settings"),
          _drawerItem(Icons.receipt_long, "Orders"),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 120), () {
                  Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                width: 160,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      onTap: () {},
    );
  }

  // ---------------------
  // HOME CONTENT
  // ---------------------
  Widget _homeBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),

          // HERO
          SizedBox(
            height: 240,
            child: PageView.builder(
              controller: _heroController,
              itemCount: 4,
              itemBuilder: (_, i) => _heroBanner(i),
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle("Popular Items"),

          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _productController,
              itemCount: 6,
              itemBuilder: (_, index) {
                return AnimatedBuilder(
                  animation: _productController,
                  builder: (_, child) {
                    double value = 1.0;
                    if (_productController.position.hasPixels) {
                      value = _productController.page! - index;
                      value = (1 - (value.abs() * 0.30)).clamp(0.75, 1.0);
                    }
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: _productCard(index),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          _sectionTitle("Gallery"),

          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: 10,
              itemBuilder: (_, i) => _galleryImage(i),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ---------------------
  // Page Widgets
  // ---------------------
  Widget _heroBanner(int i) {
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
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _productCard(int i) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
            borderRadius: BorderRadius.circular(20),
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
                "Product ${i + 1}",
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.pink),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _galleryImage(int i) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: const Center(
        child: Text("IMAGE", style: TextStyle(color: Colors.pink)),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ---------------------
  // BUILD
  // ---------------------
  @override
  Widget build(BuildContext context) {
    Widget pageContent;

    switch (selectedIndex) {
      case 0:
        pageContent = _homeBody();
        break;

      case 1:
        pageContent = const MembershipPage(); // ← REAL MEMBERSHIP PAGE
        break;

      case 2:
        pageContent = const Center(child: Text("Cart Page", style: TextStyle(fontSize: 22)));
        break;

      case 3:
        pageContent = const Center(child: Text("Profile Page", style: TextStyle(fontSize: 22)));
        break;

      default:
        pageContent = _homeBody();
    }

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
            drawer: _buildPremiumDrawer(),
            backgroundColor: const Color(0xFFFCEEEE),
            appBar: topBar,
            body: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                      begin: Offset(selectedIndex == 0 ? -0.08 : 0.08, 0),
                      end: Offset.zero,
                    );
                    return SlideTransition(
                      position: animation.drive(offset),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: SizedBox(
                    key: ValueKey(selectedIndex),
                    width: double.infinity,
                    height: double.infinity,
                    child: pageContent,
                  ),
                ),

                PinterestArcMenu(
                  isOpen: arcOpen,
                  onMaleTap: () {
                    setState(() {
                      selectedCategory = "male";
                      arcOpen = false;
                    });
                  },
                  onFemaleTap: () {
                    setState(() {
                      selectedCategory = "female";
                      arcOpen = false;
                    });
                  },
                  onUnisexTap: () {
                    setState(() {
                      selectedCategory = "unisex";
                      arcOpen = false;
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
// Curve Clipper
// ----------------------------
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
