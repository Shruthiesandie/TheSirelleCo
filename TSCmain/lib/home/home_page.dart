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

  /// Controller for auto scrolling ribbon
  final ScrollController _scrollController = ScrollController();

  // Pages / Tabs
  final List<Widget> screens = const [
    Center(child: Text("Home Page")),
    Center(child: Text("Favourite Page")),
    AllCategoriesPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    /// Unused but keeping if you need animation later
    _marqueeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    _marqueeAnimation =
        Tween<double>(begin: 1.0, end: -1.0).animate(_marqueeController);

    /// Start auto scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  /// Auto-scroll smooth movement
  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset + 1);
      }
    }
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
                /// ⭐ HOME page only
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

                /// ⭐ All pages except home
                if (selectedIndex != 0) _backOnlyBar(),

                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: screens,
                  ),
                ),
              ],
            ),

            /// ⭐ Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNavBar(
                selectedIndex: selectedIndex,
                onItemTap: (index) {
                  setState(() => selectedIndex = index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // ⭐ BEAUTIFUL PREMIUM AUTO-SCROLL OFFER RIBBON (NO FADE ISSUE)
  // -------------------------------------------------------------------
  Widget _premiumOfferRibbon() {
    List<String> offers = [
      "💗 Flat 10% OFF on ₹1000+ orders",
      "✨ 20% OFF on ₹4000+ purchases",
      "⭐ Members get extra 5% cashback",
      "🚚 Free Delivery on prepaid orders",
    ];

    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 9999,
            itemBuilder: (_, i) {
              String offer = offers[i % offers.length];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [
                      Colors.pinkAccent.withOpacity(0.17),
                      Colors.white.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.15),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  offer,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.pink.shade900,
                  ),
                ),
              );
            },
          ),

          /// ⭐ Soft fade edges — NOT blocking text visibility
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.12, 0.88, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // ⭐ Back bar for pages other than home
  // -------------------------------------------------------------------
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