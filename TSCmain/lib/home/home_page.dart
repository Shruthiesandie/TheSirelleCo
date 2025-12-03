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

      // Drawer
      drawer: const HomeDrawer(),

      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Home top section
                if (selectedIndex == 0) ...[
                  _marqueeStrip(),
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

                // Back bar for non-home
                if (selectedIndex != 0) _backOnlyBar(),

                // Screens remain loaded
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: screens,
                  ),
                ),
              ],
            ),

            // Bottom nav
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNavBar(
                selectedIndex: selectedIndex,
                onItemTap: (index) {
                  // If categories (middle icon) tapped -> open page
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
  // OFFER STRIP (top moving text)
  // -----------------------------------------------------------
  Widget _marqueeStrip() {
    return Container(
      height: 28,
      width: double.infinity,
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
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: _marqueeAnimation,
        builder: (context, child) {
          return FractionalTranslation(
            translation: Offset(_marqueeAnimation.value, 0),
            child: child,
          );
        },
        child: const Text(
          "  offer available  offer available  offer available  offer available  ",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // BACK BAR for non-home screens
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