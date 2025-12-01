// lib/home/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';
import '../pages/membership_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int selectedIndex = 0; // 0 home, 1 membership, 2 cart, 3 profile
  bool arcOpen = false;
  String selectedCategory = "none";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final PageController _heroController;
  late final PageController _productController;
  late final ScrollController _galleryController;

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

  // Swipe from left to return to home
  double _dragStartX = 0;
  bool _draggingFromEdge = false;

  void _handleHorizontalDragStart(DragStartDetails d) {
    _dragStartX = d.globalPosition.dx;
    _draggingFromEdge = _dragStartX < 32 && selectedIndex != 0;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails d) {
    if (!_draggingFromEdge) return;
    if (d.delta.dx > 12) {
      setState(() {
        selectedIndex = 0;
        arcOpen = false;
      });
      _draggingFromEdge = false;
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails d) {
    _draggingFromEdge = false;
  }

  // Bottom Nav Tap
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

  // Bottom bar
  Widget _bottomNavBar() {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
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
                        offset: const Offset(0, 8))
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

  // Icons with scale animation
  Widget _navIcon(IconData icon, int index) {
    final bool isSelected = selectedIndex == index;
    final bool wasTapped = _lastTappedIcon == index;

    return GestureDetector(
      onTap: () => _onNavIconTap(index),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 420),
        curve: const Cubic(0.22, 1.2, 0.38, 1),
        tween: Tween(begin: 1, end: wasTapped ? 0.78 : (isSelected ? 1.02 : 1)),
        builder: (_, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Icon(icon,
                size: 28, color: isSelected ? Colors.pinkAccent : Colors.grey),
          );
        },
      ),
    );
  }

  // HOME TOP BAR
  Widget _homeTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          _glassIconButton(Icons.menu, () => _scaffoldKey.currentState!.openDrawer()),
          const Spacer(),
          SizedBox(
              height: 70,
              child: Image.asset("assets/logo/logo.png", fit: BoxFit.contain)),
          const Spacer(),
          Row(
            children: [
              _glassIconButton(Icons.search, () => Navigator.pushNamed(context, "/search")),
              const SizedBox(width: 10),
              _glassIconButton(Icons.favorite_border,
                  () => Navigator.pushNamed(context, "/love")),
            ],
          ),
        ],
      ),
    );
  }

  // SUB-PAGE TOP BAR
  Widget _subPageTopBar() {
    return Container(
      height: 90,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => selectedIndex = 0),
            child: const Icon(Icons.arrow_back_ios, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            selectedIndex == 1
                ? "Membership"
                : selectedIndex == 2
                    ? "Cart"
                    : "Profile",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _glassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.55),
          border: Border.all(color: Colors.white70),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }

  // Drawer
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
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text("Menu",
                  style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
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
                Future.delayed(const Duration(milliseconds: 150), () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/login", (route) => false);
                });
              },
              child: Container(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Logout",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          )
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

  // HOME BODY
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
              itemBuilder: (_, index) => _heroBanner(index),
            ),
          ),

          const SizedBox(height: 20),
          _sectionTitle("Popular Items"),

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

                    if (_productController.hasClients &&
                        _productController.position.hasPixels &&
                        _productController.position.haveDimensions) {
                      final page = _productController.page ?? _productController.initialPage.toDouble();
                      value = (1 - ((page - index).abs() * 0.30)).clamp(0.75, 1.0);
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
              controller: _galleryController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
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

  // Dummy pages (cart + profile)
  Widget _cartPage() => const Center(child: Text("Cart Page"));
  Widget _profilePage() => const Center(child: Text("Profile Page"));

  // Reusable elements
  Widget _sectionTitle(String txt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(children: [
        Text(txt, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))
      ]),
    );
  }

  Widget _heroBanner(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          color: Colors.pink.shade200,
          child: const Center(
              child: Text("IMAGE",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22))),
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
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text("IMAGE")),
              ),
            ),
            const SizedBox(height: 10),
            Text("Product ${index + 1}",
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.pink)),
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
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: const Center(
          child: Text("IMAGE",
              style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w600))),
    );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    Widget pageContent;

    switch (selectedIndex) {
      case 0:
        pageContent = _homeBody();
        break;

      case 1:
        pageContent = const MembershipPage();  // <-- REAL MEMBERSHIP PAGE
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

    return GestureDetector(
      onHorizontalDragStart: _handleHorizontalDragStart,
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFFCEEEE),
          drawer: _buildPremiumDrawer(),
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(90),
              child: selectedIndex == 0 ? _homeTopBar() : _subPageTopBar()),
          body: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                          begin: Offset(selectedIndex == 0 ? -0.08 : 0.08, 0),
                          end: Offset.zero)
                      .animate(animation);

                  return SlideTransition(
                      position: slide,
                      child: FadeTransition(opacity: animation, child: child));
                },
                child: Container(
                  key: ValueKey(selectedIndex),
                  width: double.infinity,
                  height: double.infinity,
                  child: pageContent,
                ),
              ),

              // Arc menu always above
              PinterestArcMenu(
                isOpen: arcOpen,
                onMaleTap: () => setState(() {
                  arcOpen = false;
                  selectedCategory = "male";
                }),
                onFemaleTap: () => setState(() {
                  arcOpen = false;
                  selectedCategory = "female";
                }),
                onUnisexTap: () => setState(() {
                  arcOpen = false;
                  selectedCategory = "unisex";
                }),
              ),
            ],
          ),
          bottomNavigationBar: _bottomNavBar(),
        ),
      ),
    );
  }
}
