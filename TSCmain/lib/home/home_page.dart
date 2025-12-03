import 'package:flutter/material.dart';
import '../widgets/pinterest_arc_menu.dart';
import '../pages/membership_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/login_page.dart';

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
        top: true,
        bottom: false,
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

  // ------------------ PREMIUM SCROLL BODY ------------------
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
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ------------------ OFFER STRIP ------------------
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

  Widget _backOnlyBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () {
              setState(() {
                selectedIndex = 0;
                arcOpen = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _homeTopBar() {
    double logoShift = 20;

    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, size: 24),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            ),
            Transform.translate(
              offset: Offset(logoShift, 0),
              child: Image.asset(
                "assets/logo/logo.png",
                height: 75,
                width: 75,
                fit: BoxFit.contain,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search, size: 22),
                  onPressed: () => Navigator.pushNamed(context, "/search"),
                ),
                IconButton(
                  icon: const Icon(Icons.workspace_premium, size: 22),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MembershipPage()),
                    );
                  },
                ),
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
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.pinkAccent),
            child: Text("Menu",
                style: TextStyle(color: Colors.white, fontSize: 22)),
          ),
          ListTile(
            title: const Text("Profile"),
            onTap: () =>
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
          ListTile(
            title: const Text("Orders"),
            onTap: () => Navigator.pushNamed(context, "/orders"),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------------
// ⭐ CURVED + ELASTIC ANIMATED BOTTOM BAR ADDED HERE
// ------------------------------------------------------------------------

class AnimatedBottomBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const AnimatedBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<AnimatedBottomBar> createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _xController;
  late AnimationController _yController;

  @override
  void initState() {
    _xController = AnimationController(vsync: this);
    _yController = AnimationController(vsync: this);

    Listenable.merge([_xController, _yController]).addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _xController.value =
        _indexToPosition(widget.selectedIndex) / MediaQuery.of(context).size.width;
    _yController.value = 1.0;
    super.didChangeDependencies();
  }

  void _handleTap(int index) {
    if (widget.selectedIndex == index || _xController.isAnimating) return;
    widget.onTap(index);

    _yController.value = 1.0;
    _xController.animateTo(
        _indexToPosition(index) / MediaQuery.of(context).size.width,
        duration: const Duration(milliseconds: 600));

    _yController.animateTo(0.0, duration: const Duration(milliseconds: 250));
    Future.delayed(const Duration(milliseconds: 350), () {
      _yController.animateTo(1.0, duration: const Duration(milliseconds: 1200));
    });
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const height = 70.0;

    return SizedBox(
      width: size.width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            width: size.width,
            height: height - 10,
            child: CustomPaint(
              painter: BackgroundCurvePainter(
                _xController.value * size.width,
                Tween<double>(
                  begin: Curves.easeInExpo.transform(_yController.value),
                  end: ElasticOutCurve(0.38).transform(_yController.value),
                ).transform(_yController.velocity.sign * 0.5 + 0.5),
                Colors.white,
              ),
            ),
          ),
          Positioned(
            left: (size.width - _getButtonContainerWidth()) / 2,
            top: 0,
            width: _getButtonContainerWidth(),
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navIcon(Icons.home, 0),
                _navIcon(Icons.favorite_border, 1),
                _navIcon(Icons.grid_view, 2),
                _navIcon(Icons.shopping_cart, 3),
                _navIcon(Icons.person, 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final active = widget.selectedIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => _handleTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: active ? Alignment.topCenter : Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: active ? 40 : 22,
            decoration: BoxDecoration(
              color: active ? Colors.pinkAccent : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                if (active)
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 3,
                  )
              ],
            ),
            child: Icon(
              icon,
              size: 18,
              color: active ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  double _indexToPosition(int index) {
    const buttonCount = 5.0;
    final width = MediaQuery.of(context).size.width;
    final containerWidth = _getButtonContainerWidth();
    final startX = (width - containerWidth) / 2;

    return startX +
        index * (containerWidth / buttonCount) +
        containerWidth / (buttonCount * 2);
  }

  double _getButtonContainerWidth() {
    double width = MediaQuery.of(context).size.width;
    if (width > 420.0) width = 420.0;
    return width;
  }
}

// ------------------------------------------------------------------------
// Curve Painter + helpers
// ------------------------------------------------------------------------

class BackgroundCurvePainter extends CustomPainter {
  static const _radiusTop = 50.0;
  static const _radiusBottom = 30.0;
  static const _horizontalControlTop = 0.6;
  static const _horizontalControlBottom = 0.5;
  static const _pointControlTop = 0.35;
  static const _pointControlBottom = 0.85;
  static const _topY = -60.0;
  static const _bottomY = 0.0;
  static const _topDistance = 0.0;
  static const _bottomDistance = 10.0;

  final double _x;
  final double _normalizedY;
  final Color _color;

  BackgroundCurvePainter(this._x, this._normalizedY, this._color);

  @override
  void paint(Canvas canvas, Size size) {
    final norm = LinearPointCurve(0.5, 2.0).transform(_normalizedY) / 5;

    final radius = Tween<double>(
      begin: _radiusTop,
      end: _radiusBottom,
    ).transform(norm);

    final anchorControlOffset = Tween<double>(
      begin: radius * _horizontalControlTop,
      end: radius * _horizontalControlBottom,
    ).transform(LinearPointCurve(0.5, 0.75).transform(norm));

    final dipControlOffset = Tween<double>(
      begin: radius * _pointControlTop,
      end: radius * _pointControlBottom,
    ).transform(LinearPointCurve(0.5, 0.8).transform(norm));

    final y = Tween<double>(
      begin: _topY,
      end: _bottomY,
    ).transform(LinearPointCurve(0.2, 0.7).transform(norm));

    final dist = Tween<double>(
      begin: _topDistance,
      end: _bottomDistance,
    ).transform(LinearPointCurve(0.5, 0.0).transform(norm));

    final x0 = _x - dist / 2;
    final x1 = _x + dist / 2;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(x0 - radius, 0)
      ..cubicTo(x0 - radius + anchorControlOffset, 0,
          x0 - dipControlOffset, y, x0, y)
      ..lineTo(x1, y)
      ..cubicTo(x1 + dipControlOffset, y,
          x1 + radius - anchorControlOffset, 0, x1 + radius, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    final paint = Paint()..color = _color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundCurvePainter oldDelegate) {
    return _x != oldDelegate._x ||
        _normalizedY != oldDelegate._normalizedY ||
        _color != oldDelegate._color;
  }
}

class LinearPointCurve extends Curve {
  final double pIn;
  final double pOut;

  LinearPointCurve(this.pIn, this.pOut);

  @override
  double transform(double x) {
    final lowerScale = pOut / pIn;
    final upperScale = (1.0 - pOut) / (1.0 - pIn);
    final upperOffset = 1.0 - upperScale;
    return x < pIn ? x * lowerScale : x * upperScale + upperOffset;
  }
}

class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double curve = 25;
    return Path()
      ..lineTo(0, size.height - curve)
      ..quadraticBezierTo(
          size.width / 2, size.height + curve, size.width, size.height - curve)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
