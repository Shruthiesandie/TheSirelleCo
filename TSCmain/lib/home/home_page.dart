import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selected = 0;
  bool _arcOpen = false;
  String _selectedCategory = "none";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late PageController _carouselController;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(viewportFraction: 0.70);
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

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

          // ---------------------------------------------------------
          // TOP BAR (YOUR SAME DESIGN)
          // ---------------------------------------------------------
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: ClipPath(
              clipper: TopBarClipper(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.85),
                      Colors.white.withOpacity(0.98),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                        offset: const Offset(100, 0),
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Image.asset(
                            "assets/logo/logo.png",
                            fit: BoxFit.contain,
                            color: null,
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
              ),
            ),
          ),

          // ---------------------------------------------------------
          // BODY CONTENT
          // ---------------------------------------------------------
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // ---------------------------------------------------------
                    // HERO + CAROUSEL
                    // ---------------------------------------------------------
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFAFCF),
                            Color(0xFFFFD6E7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            "Discover Flavors",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Swipe through our handmade delights",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ************ 3D ZOOM CAROUSEL ************
                          SizedBox(
                            height: 260,
                            child: PageView.builder(
                              itemCount: 6,
                              controller: _carouselController,
                              itemBuilder: (context, index) {
                                return AnimatedBuilder(
                                  animation: _carouselController,
                                  builder: (context, child) {
                                    double value = 1.0;

                                    if (_carouselController.position.haveDimensions) {
                                      value = _carouselController.page! - index;
                                      value = (1 - (value.abs() * 0.30))
                                          .clamp(0.75, 1.0);
                                    }

                                    return Center(
                                      child: SizedBox(
                                        height: Curves.easeOut.transform(value) * 260,
                                        width: Curves.easeOut.transform(value) * 200,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _carouselCard(index),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),

                    // ---------------------------------------------------------
                    // Wave Divider
                    // ---------------------------------------------------------
                    ClipPath(
                      clipper: _WaveClipper(),
                      child: Container(
                        height: 70,
                        color: const Color(0xFFFFD6E7),
                      ),
                    ),

                    // ---------------------------------------------------------
                    // ABOUT SECTION
                    // ---------------------------------------------------------
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.white,
                      child: Column(
                        children: [
                          const Text(
                            "Crafted With Love",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.pink,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Premium handcrafted treats for every moment.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),

                          const SizedBox(height: 20),
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(child: Text("ABOUT IMAGE")),
                          ),

                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _smallFeatureCard("Fresh\nIngredients"),
                              _smallFeatureCard("Premium\nQuality"),
                              _smallFeatureCard("Handmade\nDaily"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------
                    // GALLERY (Horizontal scroll)
                    // ---------------------------------------------------------
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(left: 20),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => _galleryItem(),
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemCount: 10,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------
                    // TESTIMONIALS (Horizontal)
                    // ---------------------------------------------------------
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(left: 20),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => _testimonialCard(),
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemCount: 5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------
                    // FOOTER
                    // ---------------------------------------------------------
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD6E7),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(26),
                          topRight: Radius.circular(26),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Follow Us",
                            style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.w800,
                                fontSize: 24),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialIcon(Icons.facebook),
                              const SizedBox(width: 14),
                              _socialIcon(Icons.camera_alt),
                              const SizedBox(width: 14),
                              _socialIcon(Icons.play_circle_fill),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),

              // Arc menu on top
              PinterestArcMenu(
                isOpen: _arcOpen,
                onMaleTap: () {
                  setState(() {
                    _arcOpen = false;
                    _selectedCategory = "male";
                  });
                },
                onFemaleTap: () {
                  setState(() {
                    _arcOpen = false;
                    _selectedCategory = "female";
                  });
                },
                onUnisexTap: () {
                  setState(() {
                    _arcOpen = false;
                    _selectedCategory = "unisex";
                  });
                },
              ),
            ],
          ),

          bottomNavigationBar: _buildAestheticNavBar(),
        ),
      ),
    );
  }

  // **********************************************************************
  // GLASS ICON BUTTON  (THIS WAS MISSING EARLIER)
  // **********************************************************************
  Widget _glassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.55),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
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
          color: Colors.black87,
          size: 22,
        ),
      ),
    );
  }

  // **********************************************************************
  // DRAWER
  // **********************************************************************
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
                  color: Colors.white,
                  fontSize: 26,
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
            padding: const EdgeInsets.only(bottom: 26),
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
                  SizedBox(width: 6),
                  Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink.shade400),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {},
    );
  }

  // **********************************************************************
  // BOTTOM NAV BAR
  // **********************************************************************
  Widget _buildAestheticNavBar() {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
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
          Positioned(
            bottom: 8,
            child: GestureDetector(
              onTap: () => setState(() => _arcOpen = !_arcOpen),
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
                  _selectedCategory == "male"
                      ? Icons.male
                      : _selectedCategory == "female"
                          ? Icons.female
                          : _selectedCategory == "unisex"
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
          _selected = index;
          _arcOpen = false;
        });

        if (index == 0) Navigator.pushNamed(context, "/home");
        if (index == 1) Navigator.pushNamed(context, "/membership");
        if (index == 3) Navigator.pushNamed(context, "/cart");
        if (index == 4) Navigator.pushNamed(context, "/profile");
      },
      child: Icon(
        icon,
        color: _selected == index ? Colors.pinkAccent : Colors.grey,
        size: 28,
      ),
    );
  }

  // **********************************************************************
  // CAROUSEL CARD
  // **********************************************************************
  Widget _carouselCard(int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(child: Text("PRODUCT IMG")),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Product ${index + 1}",
            style: const TextStyle(
              color: Colors.pink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // **********************************************************************
  // FEATURE CARDS
  // **********************************************************************
  Widget _smallFeatureCard(String label) {
    return Container(
      height: 120,
      width: 110,
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // **********************************************************************
  // GALLERY ITEM
  // **********************************************************************
  Widget _galleryItem() {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text("IMG")),
    );
  }

  // **********************************************************************
  // TESTIMONIAL CARD
  // **********************************************************************
  Widget _testimonialCard() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: Colors.pink),
              SizedBox(width: 10),
              Text("Customer", style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: Text(
              "Amazing taste and super fresh! Highly recommended.",
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // **********************************************************************
  // SOCIAL ICON
  // **********************************************************************
  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.pink.shade300,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

// --------------------------------------------------------------
// TOP BAR CURVE CLIPPER
// --------------------------------------------------------------
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --------------------------------------------------------------
// WAVE CLIPPER
// --------------------------------------------------------------
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height * 0.7);
    p.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.7,
    );
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
