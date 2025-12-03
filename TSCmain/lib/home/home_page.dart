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

  @override
  void initState() {
    super.initState();

    _marqueeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();

    _marqueeAnimation =
        Tween<double>(begin: 1.0, end: -1.0).animate(_marqueeController);
  }

  @override
  void dispose() {
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
                  _blinkingOfferStrip(),
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
  // 🔥 NEW BLINKING AUTO ROTATING OFFER STRIP
  // -----------------------------------------------------------
  Widget _blinkingOfferStrip() {
    return SizedBox(
      height: 28,
      width: double.infinity,
      child: _BlinkingOfferSlider(),
    );
  }

  // -----------------------------------------------------------
  // BACK BAR
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

// =====================================================================
// ⭐ Internal widget: blinking sliding offer text — aesthetic animation
// =====================================================================
class _BlinkingOfferSlider extends StatefulWidget {
  @override
  State<_BlinkingOfferSlider> createState() => _BlinkingOfferSliderState();
}

class _BlinkingOfferSliderState extends State<_BlinkingOfferSlider> {
  final List<String> offers = [
    "✨ 10% OFF on orders above ₹1000 ✨",
    "🔥 20% OFF on orders above ₹4000 🔥",
    "🚚 Free Delivery on prepaid orders 🚚",
  ];

  int index = 0;

  @override
  void initState() {
    super.initState();
    _cycleOffers();
  }

  void _cycleOffers() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => index = (index + 1) % offers.length);
      _cycleOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
          const BoxShadow(
            color: Color(0xFFEAEAEA),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.6, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutExpo,
          ));

          return SlideTransition(
            position: slideAnimation,
            child: child,
          );
        },
        child: Text(
          offers[index],
          key: ValueKey(index),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}