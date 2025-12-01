// lib/home/home_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';
import '../pages/membership_page.dart';

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
  late final PageController _testimonialsController;

  // For nav icon tap animation
  int _lastTappedIcon = -1;

  // Small animation controllers for floating decor
  late final AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _heroController = PageController(viewportFraction: 0.92);
    _productController = PageController(viewportFraction: 0.72);
    _galleryController = ScrollController();
    _testimonialsController = PageController(viewportFraction: 0.92);
    _floatingController = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _productController.dispose();
    _galleryController.dispose();
    _testimonialsController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  // iOS-like left-edge swipe (go back to home if not on home)
  double _dragStartX = 0.0;
  bool _draggingFromEdge = false;

  void _handleHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _draggingFromEdge = _dragStartX < 32 && selectedIndex != 0;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_draggingFromEdge) return;
    final delta = details.delta.dx;
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

  // micro "spring" tap on bottom icons
  void _onNavIconTap(int index) {
    setState(() {
      _lastTappedIcon = index;
      selectedIndex = index;
      arcOpen = false;
    });
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) setState(() => _lastTappedIcon = -1);
    });
  }

  // ------------------------------
  // TOP BAR: home (curved with logo)
  // ------------------------------
  Widget _homeTopBar() {
    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.88), Colors.white.withOpacity(0.98)],
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            _glassIconButton(Icons.menu, () => _scaffoldKey.currentState?.openDrawer()),
            Expanded(
              child: Transform.translate(
                offset: const Offset(18, 0),
                child: SizedBox(
                  height: 72,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo placeholder (you can replace the container with Image.asset)
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.icecream, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Text("Scoopery", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    ],
                  ),
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
  // TOP BAR: sub-pages
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
  // GLASS ICON BUTTON
  // ----------------------
  Widget _glassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.6),
          border: Border.all(color: Colors.white.withOpacity(0.8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  // ----------------------
  // DRAWER
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
  // Bottom nav bar
  // ----------------------
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
                  gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
                  boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.32), blurRadius: 18, offset: const Offset(0, 8))],
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
    final bool isSelected = selectedIndex == index;
    final bool wasTapped = _lastTappedIcon == index;
    final double targetScale = wasTapped ? 0.78 : (isSelected ? 1.02 : 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onNavIconTap(index),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 420),
        curve: const Cubic(0.22, 1.2, 0.38, 1.0),
        tween: Tween<double>(begin: 1.0, end: targetScale),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: Icon(icon, size: 28, color: isSelected ? Colors.pinkAccent : Colors.grey));
        },
      ),
    );
  }

  // ----------------------
  // HOME BODY (REPLACED) -- Pink Ice-cream themed landing page
  // ----------------------
  Widget _homeBody() {
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          // Section 1 - Hero Header
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFE6F2), Color(0xFFFFF3F8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Column(
                  children: [
                    // nav (centered) + profile small intro
                    const SizedBox(height: 6),
                    // hero content
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              const Text("Scoop of the Day", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.w800, fontSize: 14)),
                              const SizedBox(height: 8),
                              const Text("Strawberry Dreams", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 8),
                              const Text("Creamy scoops, fresh berries and waffle crunch — made with love.", style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                    child: const Text("Order Now"),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                    child: const Text("View Menu", style: TextStyle(color: Colors.pink)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Big bowl placeholder with glow + floating decor
                        SizedBox(
                          width: width * 0.36,
                          height: width * 0.36,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // glow
                              Positioned(
                                bottom: 6,
                                child: Container(
                                  width: width * 0.34,
                                  height: width * 0.34,
                                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [
                                    Colors.pink.shade100.withOpacity(0.9),
                                    Colors.pink.shade50.withOpacity(0.2)
                                  ])),
                                ),
                              ),

                              // main bowl placeholder
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: width * 0.28,
                                  height: width * 0.28,
                                  color: Colors.pink.shade100,
                                  child: const Center(child: Text("IMAGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                ),
                              ),

                              // floating strawberry
                              Positioned(
                                top: 8,
                                left: 4,
                                child: _floatingDecor(const Icon(Icons.favorite, size: 18), -8),
                              ),

                              // floating mint leaf
                              Positioned(
                                top: 14,
                                right: 2,
                                child: _floatingDecor(const Icon(Icons.spa, size: 18), 6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // curved wave bottom
              Positioned(
                bottom: -1,
                left: 0,
                right: 0,
                child: WaveClipper(height: 48, color: Colors.white),
              ),
            ],
          ),

          // Section 2 - Featured Ice Cream Cards (3 vertical)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Featured Flavors", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Column(
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _flavorCard(i),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Section 3 - About
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    // milk jar placeholder left
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(color: Colors.pink.shade50, shape: BoxShape.circle),
                      child: const Center(child: Icon(Icons.local_drink, size: 34, color: Colors.pink)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("About Our Creamery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.pink)),
                          SizedBox(height: 8),
                          Text("We use fresh ingredients and small-batch processes. Every scoop tells a story."),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _infoCard("Natural Ingredients")),
                    const SizedBox(width: 8),
                    Expanded(child: _infoCard("Small-batch")),
                    const SizedBox(width: 8),
                    Expanded(child: _infoCard("Handmade Toppings")),
                  ],
                ),
              ],
            ),
          ),

          // Section 4 - Gallery + Testimonials
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Gallery", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),

                // grid gallery (limit height so GridView won't be unbounded)
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                    children: List.generate(6, (i) {
                      return Container(
                        decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(14)),
                        child: const Center(child: Text("IMG", style: TextStyle(color: Colors.white))),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 14),

                // Testimonials PageView
                SizedBox(
                  height: 110,
                  child: PageView.builder(
                    controller: _testimonialsController,
                    itemCount: 3,
                    itemBuilder: (ctx, idx) {
                      return _testimonialTile(idx);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Section 5 - Video preview
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                // big video preview
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(decoration: BoxDecoration(color: Colors.pink.shade100, borderRadius: BorderRadius.circular(16))),
                        const Center(child: Text("VIDEO PREVIEW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow, color: Colors.pink, size: 38),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // vertical thumbnails
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(10)),
                          child: const Center(child: Icon(Icons.image)),
                        ),
                      );
                    }),
                  ),
                )
              ],
            ),
          ),

          // Section 6 - Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _newsletterField()),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(12)),
                      child: const Text("Subscribe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: const [
                      Icon(Icons.camera_alt, color: Colors.pink),
                      SizedBox(width: 8),
                      Text("Instagram"),
                      SizedBox(width: 12),
                      Icon(Icons.facebook, color: Colors.pink),
                      SizedBox(width: 8),
                      Text("Facebook"),
                    ]),
                    const Text("© 2025 Scoopery", style: TextStyle(color: Colors.black54)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 60), // spacing for bottom bar
        ],
      ),
    );
  }

  // ----------------------
  // Helpers & small components used above
  // ----------------------
  Widget _floatingDecor(Widget child, double offsetY) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, _) {
        final t = _floatingController.value;
        final dy = sin((t * 2 * pi)) * 6 + offsetY;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
    );
  }

  Widget _flavorCard(int index) {
    final flavor = ["Vanilla", "Chocolate", "Mango"][index % 3];
    final desc = [
      "Classic and creamy",
      "Rich cocoa with fudge",
      "Tropical mango burst"
    ][index % 3];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))]),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // cone image placeholder
            Container(width: 86, height: 86, decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(14)), child: const Center(child: Text("IMG"))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(flavor, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_forward, size: 18, color: Colors.pink),
                  ),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)),
      child: Row(children: [const Icon(Icons.check_circle, color: Colors.pink), const SizedBox(width: 8), Expanded(child: Text(text))]),
    );
  }

  Widget _testimonialTile(int i) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        CircleAvatar(radius: 28, backgroundColor: Colors.white.withOpacity(0.8), child: Text("U${i + 1}")),
        const SizedBox(width: 12),
        Expanded(child: Text("“This ice-cream is amazing — flavor ${i + 1} is my favorite!”", style: const TextStyle(color: Colors.black87))),
      ]),
    );
  }

  Widget _newsletterField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Row(children: const [
        Icon(Icons.email_outlined, color: Colors.pink),
        SizedBox(width: 8),
        Expanded(child: TextField(decoration: InputDecoration.collapsed(hintText: "Enter email"))),
      ]),
    );
  }

  // ----------------------
  // Build (main)
  // ----------------------
  @override
  Widget build(BuildContext context) {
    // select page content based on index
    Widget pageContent;
    switch (selectedIndex) {
      case 0:
        pageContent = _homeBody();
        break;
      case 1:
        pageContent = const MembershipPage();
        break;
      case 2:
        pageContent = Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shopping_cart, size: 48, color: Colors.pink), SizedBox(height: 12), Text("Cart Page", style: TextStyle(fontSize: 22))]));
        break;
      case 3:
        pageContent = Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.person, size: 48, color: Colors.pink), SizedBox(height: 12), Text("Profile Page", style: TextStyle(fontSize: 22))]));
        break;
      default:
        pageContent = _homeBody();
    }

    final PreferredSizeWidget topBar = PreferredSize(preferredSize: const Size.fromHeight(90), child: selectedIndex == 0 ? _homeTopBar() : _subPageTopBar());

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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  transitionBuilder: (child, animation) {
                    final inFromLeft = selectedIndex == 0;
                    final offsetTween = Tween<Offset>(begin: Offset(inFromLeft ? -0.06 : 0.06, 0), end: Offset.zero);
                    return SlideTransition(position: animation.drive(offsetTween), child: FadeTransition(opacity: animation, child: child));
                  },
                  child: SizedBox(
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
// TopBarClipper (curved top bar)
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

// ----------------------------
// WaveClipper: draws a soft wave that blends sections
// ----------------------------
class WaveClipper extends StatelessWidget {
  final double height;
  final Color color;
  const WaveClipper({required this.height, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipPath(
        clipper: _WavePathClipper(),
        child: Container(color: color),
      ),
    );
  }
}

class _WavePathClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height;
    final w = size.width;
    path.moveTo(0, h * 0.6);
    path.quadraticBezierTo(w * 0.25, h * 0.2, w * 0.5, h * 0.6);
    path.quadraticBezierTo(w * 0.75, h * 1.0, w, h * 0.6);
    path.lineTo(w, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
