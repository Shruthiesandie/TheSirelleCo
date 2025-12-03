import 'package:flutter/material.dart';

// Pages
import '../pages/membership_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/allcategories_page.dart';

// Widgets
import '../widgets/top_bar/home_top_bar.dart';
import '../widgets/bottom_nav/home_bottom_nav_bar.dart';
import '../widgets/drawer/home_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  ScrollController _scrollController = ScrollController();

  late AnimationController shimmerController;

  // Tabs except categories
  final List<Widget> screens = const [
    Center(child: Text("Home Page")),
    Center(child: Text("Favourite Page")),
    CartPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    // Soft shimmer animation
    shimmerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    shimmerController.dispose();
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
                  _premiumOfferRibbon(),
                  HomeTopBar(
                    onMenuTap: () => _scaffoldKey.currentState!.openDrawer(),
                    onSearchTap: () => Navigator.pushNamed(context, "/search"),
                    onMembershipTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MembershipPage(),
                        ),
                      );
                    },
                  ),
                ],

                if (selectedIndex != 0) _backOnlyBar(),

                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: screens,
                  ),
                ),
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNavBar(
                selectedIndex: selectedIndex,
                onItemTap: (index) {
                  if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllCategoriesPage(),
                      ),
                    );
                  } else {
                    setState(() => selectedIndex = index >= 2 ? index - 1 : index);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // ✨ PREMIUM GLASS + SHIMMER OFFER RIBBON
  // -----------------------------------------------------------
  Widget _premiumOfferRibbon() {
    List<String> offers = [
      "💗 10% OFF above ₹1000 💗",
      "✨ 20% OFF above ₹4000 ✨",
      "⭐ Extra 5% for Members ⭐",
      "🚚 Free Delivery on prepaid 🚚",
    ];

    return SizedBox(
      height: 38,
      child: AnimatedBuilder(
        animation: shimmerController,
        builder: (context, child) {
          final glowOffset =
              (shimmerController.value * 60) - 30; // subtle shimmer
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.pinkAccent.withOpacity(0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.20),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                // ✨ glow moving effect
                Positioned(
                  left: glowOffset,
                  top: 6,
                  bottom: 6,
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.30),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),

                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: 9999,
                  itemBuilder: (_, i) {
                    String offer = offers[i % offers.length];
                    return Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.pinkAccent.withOpacity(0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        offer,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.pink.shade700,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Auto Scroll for Infinite ribbon
  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (!_scrollController.hasClients) return;

      _scrollController.jumpTo(_scrollController.offset + 0.4);

      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(0);
      }
    }
  }

  // Back bar
  Widget _backOnlyBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () {
          setState(() {
            selectedIndex = 0;
          });
        },
      ),
    );
  }
}