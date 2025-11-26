// lib/home/pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/popup_bubble_menu.dart'; // NEW widget

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _menuOpen = false;

  // controller for center FAB animation
  late final AnimationController _fabCtrl;
  late final Animation<double> _fabScale;
  late final Animation<double> _fabRotate;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fabScale = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _fabCtrl, curve: Curves.easeOut));
    _fabRotate = Tween<double>(begin: 0.0, end: 0.125).animate(CurvedAnimation(parent: _fabCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _menuOpen = !_menuOpen;
      if (_menuOpen) {
        _fabCtrl.forward();
      } else {
        _fabCtrl.reverse();
      }
    });
  }

  void _onCategorySelected(String slug) {
    // close menu and navigate (or do your handling)
    setState(() => _menuOpen = false);
    _fabCtrl.reverse();
    if (slug == 'male') {
      Navigator.pushNamed(context, '/category/male');
    } else if (slug == 'female') {
      Navigator.pushNamed(context, '/category/female');
    } else {
      Navigator.pushNamed(context, '/category/all');
    }
  }

  Widget _pageForIndex(int idx) {
    switch (idx) {
      case 0:
        return const Center(child: Text('Home Page'));
      case 1:
        return const Center(child: Text('Membership'));
      case 2:
        return const Center(child: Text('All Categories (placeholder)'));
      case 3:
        return const Center(child: Text('Cart Page'));
      case 4:
        return const Center(child: Text('Profile Page'));
    }
    return const Center(child: Text('Home Page'));
  }

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
        ),
        child: ListView(padding: EdgeInsets.zero, children: const [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFFC1E3), Color(0xFFB4F8C8)]),
            ),
            child: Text("Hello, User 🎀", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.white,
          child: SafeArea(
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.menu, size: 28), onPressed: () => _scaffoldKey.currentState!.openDrawer()),
                Expanded(child: Center(child: Image.asset('assets/logo/logo.png', height: 64, width: 64, fit: BoxFit.contain))),
                Row(children: [
                  IconButton(icon: const Icon(Icons.search, size: 26), onPressed: () => Navigator.pushNamed(context, '/search')),
                  IconButton(icon: const Icon(Icons.favorite, size: 26), onPressed: () => Navigator.pushNamed(context, '/love')),
                ])
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(child: _pageForIndex(_selectedIndex)),

          // bubble menu overlay (handles tap-out to close)
          PopupBubbleMenu(
            open: _menuOpen,
            onClose: () {
              setState(() {
                _menuOpen = false;
                _fabCtrl.reverse();
              });
            },
            onSelect: _onCategorySelected,
          ),

          // center floating + button overlayed above the bottom nav
          Positioned(
            bottom: safeBottom + 28, // distance above bottom nav icons
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _toggleMenu();
                },
                child: AnimatedBuilder(
                  animation: _fabCtrl,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _fabRotate.value,
                      child: Transform.scale(
                        scale: _fabScale.value,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 6))],
                          ),
                          child: Center(
                            child: Icon(Icons.add, color: const Color(0xFFE9446A), size: 30),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 28,
        onTap: (index) {
          // center area toggles popup instead of changing page
          if (index == 2) {
            _toggleMenu();
            return;
          }
          setState(() {
            _selectedIndex = index;
            if (_menuOpen) {
              _menuOpen = false;
              _fabCtrl.reverse();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.card_membership), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ''), // center
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
