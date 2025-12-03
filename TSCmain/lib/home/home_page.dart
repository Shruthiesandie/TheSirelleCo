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

  late final AnimationController _marqueeController;
  late final Animation<double> _marqueeAnimation;

  // Tabs except categories
  final List<Widget> screens = const [
    Center(child: Text("Home Page")),
    Center(child: Text("Favourite Page")),
    CartPage(),
    ProfilePage(),
  ];

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    /// Start auto drifting after rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });

    _marqueeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();

    _marqueeAnimation =
        Tween<double>(begin: 1.0, end: -1.0).animate(_marqueeController);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _marqueeController.dispose();
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
  // ✨ PREMIUM DRIFTING OFFER RIBBON
  // -----------------------------------------------------------
  Widget _premiumOfferRibbon() {
    List<String> offers = [
      "💗 10% OFF above ₹1000 💗",
      "✨ 20% OFF above ₹4000 ✨",
      "⭐ Extra 5% for Members ⭐",
      "🚚 Free Delivery on prepaid 🚚",
    ];

    return SizedBox(
      height: 35,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.pinkAccent.withOpacity(0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.15),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 9999, // infinite illusion
          itemBuilder: (_, i) {
            String offer = offers[i % offers.length];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(30),
                border:
                    Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
              ),
              child: Text(
                offer,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.pinkAccent,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // 🔁 AUTO SCROLLING ANIMATION
  // -----------------------------------------------------------
  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 20)); // slower & smooth
      if (!_scrollController.hasClients) return;

      _scrollController.jumpTo(_scrollController.offset + 0.5);

      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(0);
      }
    }
  }

  // -----------------------------------------------------------
  // BACK BAR (non-home)
  // -----------------------------------------------------------
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