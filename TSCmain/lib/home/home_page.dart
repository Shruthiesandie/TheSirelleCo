import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';
import '../pages/membership_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/login_page.dart';
import '../widgets/BottomNavigationBar/bottom_navigation_bar.dart';
import '../widgets/top_bar_clipper.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;
  bool arcOpen = false;

  late final AnimationController _marqueeController;
  late final Animation<double> _marqueeAnimation;

  final List<Widget> screens = [];

  @override
  void initState() {
    super.initState();

    screens.addAll([
      _buildHomeScrollBody(),
      const Center(child: Text("Favourite Page")),
      const Center(child: Text("All Categories Page")),
      const CartPage(),
      const ProfilePage(),
    ]);

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
      drawer: _drawer(),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (selectedIndex == 0) ...[
                  _marqueeStrip(),
                  _homeTopBar(),
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

            /// bottom bar imported
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBottomBar(
                selectedIndex: selectedIndex,
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
                    arcOpen = false;
                  });
                },
              ),
            ),

            PinterestArcMenu(
              isOpen: arcOpen,
              onMaleTap: () => _setCategory("male"),
              onFemaleTap: () => _setCategory("female"),
              onUnisexTap: () => _setCategory("unisex"),
            ),
          ],
        ),
      ),
    );
  }

  void _setCategory(String _) {
    setState(() => arcOpen = false);
  }

  Widget _buildHomeScrollBody() {
    return CustomScrollView(
      slivers: [
        _sectionBox("Offers & Categories"),
        _sectionBox("Popular Products"),
        _sectionBox("Flash Sale"),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _bannerBox("New Arrival — Special Offer"),
          ),
        ),
        _sectionBox("Best Sellers"),
        _sectionBox("Most Popular"),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _bannerBox("Black Friday — 50% OFF"),
          ),
        ),
        _sectionBox("Best Sellers"),
      ],
    );
  }

  SliverToBoxAdapter _sectionBox(String title) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _bannerBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _marqueeStrip() {
    return SizedBox(
      height: 28,
      child: AnimatedBuilder(
        animation: _marqueeAnimation,
        builder: (context, child) {
          return FractionalTranslation(
            translation: Offset(_marqueeAnimation.value, 0),
            child: child,
          );
        },
        child: const Text(
          "  offer available offer available offer available offer available  ",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _backOnlyBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => setState(() => selectedIndex = 0),
        ),
      ],
    );
  }

  Widget _homeTopBar() {
    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        height: 90,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState!.openDrawer()),
            Image.asset("assets/logo/logo.png", height: 75, width: 75),
            Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => Navigator.pushNamed(context, "/search")),
                IconButton(
                    icon: const Icon(Icons.workspace_premium),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MembershipPage()))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Drawer _drawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.pinkAccent),
            child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 22)),
          ),
          ListTile(
            title: const Text("Profile"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
          ListTile(
            title: const Text("Orders"),
            onTap: () => Navigator.pushNamed(context, "/orders"),
          ),
          ListTile(
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          ),
        ],
      ),
    );
  }
}
