import 'package:flutter/material.dart';

// pages
import '../pages/membership_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/allcategories_page.dart';

// widgets
import '../widgets/top_bar/home_top_bar.dart';
import '../widgets/bottom_nav/home_bottom_nav_bar.dart';
import '../widgets/drawer/home_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  late final ScrollController _scrollController;
  late AnimationController marqueeController;

  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    screens = [
      const CupcakeHomeTab(),
      const Center(child: Text("Wishlist")),
      AllCategoriesPage(onBackToHome: () {
        setState(() => selectedIndex = 0);
      }),
      const CartPage(),
      const ProfilePage(),
    ];

    marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) => autoScrollRibbon());
  }

  void autoScrollRibbon() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset + 1);
      }
    }
  }

  @override
  void dispose() {
    marqueeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFCEEEE),
      drawer: const HomeDrawer(),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                if (selectedIndex == 0) ...[
                  _premiumRibbon(),
                  HomeTopBar(
                    onMenuTap: () => _scaffoldKey.currentState!.openDrawer(),
                    onSearchTap: () => Navigator.pushNamed(context, "/search"),
                    onMembershipTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MembershipPage()),
                      );
                    },
                  ),
                ],
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: screens,
                  ),
                ),
              ],
            ),

            /// floating bottom nav (your widget)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNavBar(
                selectedIndex: selectedIndex,
                onItemTap: (index) => setState(() => selectedIndex = index),
              ),
            )
          ],
        ),
      ),
    );
  }

  // PREMIUM SCROLLER
  Widget _premiumRibbon() {
    List<String> offers = [
      "💗 Flat 10% OFF on ₹1000+ orders",
      "✨ 20% OFF on ₹4000+ purchases",
      "⭐ Extra Cashback for Members",
      "🚚 Free Delivery on Prepaid",
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: offers.length * 4,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemBuilder: (_, i) {
          String offer = offers[i % offers.length];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.pinkAccent.withOpacity(.17),
                  Colors.white.withOpacity(.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(.15),
                  blurRadius: 8,
                )
              ],
            ),
            child: Text(
              offer,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.pink.shade900,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// CUPCAKE STYLE HOME TAB
class CupcakeHomeTab extends StatefulWidget {
  const CupcakeHomeTab({super.key});
  @override
  State<CupcakeHomeTab> createState() => _CupcakeHomeTabState();
}

class _CupcakeHomeTabState extends State<CupcakeHomeTab> {
  double scrollOffset = 0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() => scrollOffset = notification.metrics.pixels.clamp(0, 200));
        }
        return true;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFCEEEE),
                Color(0xFFF8C6D0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) => Transform.scale(
                  scale: value * (1 - (scrollOffset / 450)),
                  child: Opacity(opacity: (1 - scrollOffset / 200).clamp(0, 1), child: child),
                ),
                child: Container(
                  height: 220,
                  alignment: Alignment.center,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.55),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(.35),
                          blurRadius: 28,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 70,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) => Opacity(
                  opacity: (value * (1 - scrollOffset / 260)).clamp(0, 1),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value) + scrollOffset * 0.3),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Buttery Cupcakes",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Playfair Display",
                        color: Colors.pink.shade700,
                      ),
                    ),
                    Text(
                      "Freshly baked with love 🍰",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.pink.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(0, 40 * (1 - value) - scrollOffset * 0.4),
                  child: Opacity(opacity: value, child: child),
                ),
                child: ClipPath(
                  clipper: CupcakeCurveClipper(),
                  child: Container(
                    height: 260,
                    width: double.infinity,
                    color: Colors.pink.shade300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_bag_rounded,
                            size: 24,
                            color: Colors.pink,
                          ),
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.pink.shade600,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Customize your Cupcake",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "More →",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CupcakeCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();

    p.lineTo(0, size.height * .20);

    p.quadraticBezierTo(
      size.width * 0.25,
      0,
      size.width * 0.5,
      size.height * .18,
    );

    p.quadraticBezierTo(
      size.width * 0.75,
      size.height * .36,
      size.width,
      size.height * .18,
    );

    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);

    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}