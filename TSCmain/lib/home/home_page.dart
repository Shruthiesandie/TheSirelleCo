// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'dart:async';

// Pages
import '../pages/membership_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/allcategories_page.dart';
import '../pages/product_details_page.dart';
import '../pages/love_page.dart';

// Widgets
import '../widgets/top_bar/home_top_bar.dart';
import '../widgets/bottom_nav/home_bottom_nav_bar.dart';
import '../widgets/drawer/home_drawer.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../controllers/favorites_controller.dart';
import '../services/recommendation_engine.dart';

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
  final ScrollController _scrollController = ScrollController();

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      Container(), // Home screen EMPTY — products removed
      const LovePage(), // ❤️ Favourite screen
      AllCategoriesPage(
        onBackToHome: () {
          setState(() => selectedIndex = 0);
        },
      ),
      const CartPage(),
      const ProfilePage(),
    ];

    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

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
      extendBody: true,

      body: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (selectedIndex == 0) ...[
                    _premiumOfferRibbon(),
                    HomeTopBar(
                      onMenuTap: () => _scaffoldKey.currentState!.openDrawer(),
                      onSearchTap: () =>
                          Navigator.pushNamed(context, "/search"),
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

                  Expanded(
                    child: selectedIndex == 0
                        ? _HomeContent()
                        : IndexedStack(index: selectedIndex, children: screens),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 20,
              bottom: 90,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/sirelle-chat");
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9ACB), Color(0xFFFFC1D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Ask Sirelle AI",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

  // ⭐ BEAUTIFUL PREMIUM AUTO-SCROLL + USER-SCROLL OFFER RIBBON
  // -------------------------------------------------------------------
  Widget _premiumOfferRibbon() {
    List<String> offers = [
      "💗 Flat 10% OFF on ₹1000+ orders",
      "✨ 20% OFF on ₹4000+ purchases",
      "⭐ Members get extra 5% cashback",
      "🚚 Free Delivery on prepaid orders",
    ];

    return SizedBox(
      height: 42,
      child: Listener(
        onPointerMove: (details) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.offset - details.delta.dx,
            );
          }
        },
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                      fontSize: 12.8,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink.shade900,
                    ),
                  ),
                );
              },
            ),

            /// ⭐ Soft fade edges — aesthetic, not blocking scroll
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
      ),
    );
  }
}

// ------------------------ SECTION HEADER SHARED HELPER ------------------------
Widget _sectionHeader(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Row(
      children: [
        const Expanded(
          child: Divider(thickness: 1.2, color: Color(0xFFf3c6d4)),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE4EC), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.25),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Color(0xFFB2004D),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Divider(thickness: 3.0, color: Color(0xFFf3c6d4)),
        ),
      ],
    ),
  );
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  Widget build(BuildContext context) {
    final List<Product> shuffled = List<Product>.from(products)..shuffle();
    final recommended = RecommendationEngine.recommend(
      allProducts: products,
      category: null,
      budget: null,
      vibe: null,
    );

    final month = DateTime.now().month;
    final bool festive = (month == 10 || month == 11); // Diwali window
    final bool valentine = (month == 2);

    final heroGradient = festive
        ? const LinearGradient(colors: [Color(0xFFFFE082), Color(0xFFFFF7E0)])
        : valentine
        ? const LinearGradient(colors: [Color(0xFFFFC1D9), Color(0xFFFFF1F6)])
        : const LinearGradient(colors: [Color(0xFFFFE3EC), Color(0xFFFFFFFF)]);

    final heroTag = festive
        ? "Festive Picks · Limited"
        : valentine
        ? "Valentine Specials"
        : "New Arrivals · Limited Stock";

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          _ScrollFadeIn(
            delay: const Duration(milliseconds: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF1F6), Color(0xFFFFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFC1D9),
                      ),
                      child: const Icon(
                        Icons.psychology_alt,
                        color: Color(0xFFB2004D),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Smart AI Shopping Assistant",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB2004D),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Tell Sirelle your budget, vibe, or category — she instantly finds the best products for you. No filters, no scrolling.",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 1️⃣ HERO / FEATURED
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 0),
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) => false,
              child: GestureDetector(
                onTap: () {
                  RecommendationEngine.trackProductView(shuffled.first);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailsPage(product: shuffled.first),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 410,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: heroGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            shuffled.first.thumbnail,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            heroTag,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🤖 AI RECOMMENDED FOR YOU
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(context, "Recommended For You"),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recommended.take(6).length,
                    itemBuilder: (context, index) {
                      final product = recommended[index];

                      return GestureDetector(
                        onTap: () {
                          RecommendationEngine.trackProductView(product);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsPage(product: product),
                            ),
                          );
                        },
                        child: Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                  child: Image.asset(
                                    product.thumbnail,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "₹${product.price}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 2️⃣ SHOP BY CATEGORY (header removed, only cards remain)
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Transform.translate(
                  offset: const Offset(-15, -29),
                  child: SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      children: const [
                        _CategoryChip("Bottles", Icons.local_drink, "bottles"),
                        _CategoryChip(
                          "Candles",
                          Icons.local_fire_department,
                          "candle",
                        ),
                        _CategoryChip("Caps", Icons.checkroom, "caps"),
                        _CategoryChip("Ceramic", Icons.coffee, "ceramic"),
                        _CategoryChip("Hair", Icons.face, "hair_accessories"),
                        _CategoryChip("Keychains", Icons.key, "key_chain"),
                        _CategoryChip("Letters", Icons.text_fields, "letter"),
                        _CategoryChip("Nails", Icons.brush, "nails"),
                        _CategoryChip("Plushies", Icons.toys, "plusie"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height:0),

          // 🔍 EXPLORE ALL — CATEGORY STORY STRIP
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(context, "Explore All"),
                const SizedBox(height: 20),
                Column(
                  children: List.generate(_exploreItems.length, (index) {
                    final item = _exploreItems[index];
                    final bool imageLeft = index % 2 == 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      child: Row(
                        children: [
                          if (imageLeft)
                            _exploreImageFromCategory(context, item.categoryKey),
                          const SizedBox(width: 6),
                          Expanded(child: _exploreText(item.name, imageLeft: imageLeft)),
                          const SizedBox(width: 6),
                          if (!imageLeft)
                            _exploreImageFromCategory(context, item.categoryKey),
                        ],
                      ),
                    );
                  }),
                ),
                // Inserted Gift Hamper premium heading block
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          thickness: 1.2,
                          color: Color(0xFFf3c6d4),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE4EC), Color(0xFFFFFFFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.25),
                              blurRadius: 20,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Gift Hamper",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFFB2004D),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Divider(
                          thickness: 1.2,
                          color: Color(0xFFf3c6d4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // 🎁 CUSTOM GIFT HAMPER FEATURE (from sketch)
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 130),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 520,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F4),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Right semicircle bubble (true semicircle using ClipOval)
                    Positioned(
                      right: -140,
                      top: 40,
                      child: ClipOval(
                        child: Stack(
                          children: [
                            Container(
                              width: 440,
                              height: 440,
                              color: Colors.pink.shade100,
                            ),
                            // Place the shuffled product image inside the semicircle
                            Positioned.fill(
                              child: Image.asset(
                                (List<Product>.from(
                                  products,
                                )..shuffle()).first.thumbnail,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Overlay gradient for text readability
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.55),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Left content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 260, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 22,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          const Spacer(),
                          const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 0),

          _ScrollFadeIn(
            delay: const Duration(milliseconds: 150),
            child: Transform.translate(
              offset: const Offset(0, -100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFFFF3F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Introducing Gift Hampers",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: Color(0xFFB2004D),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFB2004D),
                          fontFamily: "Nunito",
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Create your own personalised gift hamper by mixing and matching products from every category. A perfect way to make your gift feel special and thoughtful.",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.55,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 0),
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 160),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllCategoriesPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE4EC), Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(
                        color: Color(0xFFFFC1D9),
                        width: 1.4,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Customize",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB2004D),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const SizedBox(height: 40),
          _BeverageAdSection(),
          const SizedBox(height: 40),

          // 3️⃣ TRENDING GRID
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(context, "Trending Right Now"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (_, i) {
                      final p = shuffled[i];
                      return GestureDetector(
                        onTap: () {
                          RecommendationEngine.trackProductView(p);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsPage(product: p),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(22),
                                      ),
                                      child: Image.asset(
                                        p.thumbnail,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "₹${p.price}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ❤️ FAVORITE BUTTON
                            Positioned(
                              top: 8,
                              right: 8,
                              child: ValueListenableBuilder<List<Product>>(
                                valueListenable: FavoritesController.items,
                                builder: (context, _, __) {
                                  final isFav = FavoritesController.contains(p);
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        isFav
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.pink,
                                      ),
                                      onPressed: () {
                                        FavoritesController.toggle(p);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // ⭐ JUST DROPPED — HORIZONTAL SCROLL
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(context, "Just Dropped"),
                const SizedBox(height: 14),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final product = shuffled[index];
                      return GestureDetector(
                        onTap: () {
                          RecommendationEngine.trackProductView(product);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsPage(product: product),
                            ),
                          );
                        },
                        child: Container(
                          width: 170,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                  child: Image.asset(
                                    product.thumbnail,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),

          // 🎁 GIFTING MOMENTS — EDITORIAL BLOCK
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 220),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE4EC), Color(0xFFFFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Gifting Moments",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Birthdays, surprises, self‑love or just because — find something meaningful.",
                        style: TextStyle(fontSize: 14, height: 1.45),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🎉 SHOP BY OCCASION
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 260),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(context, "Shop by Occasion"),
                const SizedBox(height: 14),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    children: [
                      _OccasionCard("Birthday Gifts"),
                      _OccasionCard("Anniversary"),
                      _OccasionCard("Self Care"),
                      _OccasionCard("Cute Surprises"),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),

          // 4️⃣ BRAND STORY
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF1F6), Color(0xFFFFFFFF)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "It’s Official — The Sirelle Co",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.pink, size: 18),
                        Icon(Icons.star, color: Colors.pink, size: 18),
                        Icon(Icons.star, color: Colors.pink, size: 18),
                        Icon(Icons.star, color: Colors.pink, size: 18),
                        Icon(Icons.star_half, color: Colors.pink, size: 18),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Thoughtfully crafted pieces designed to feel personal, warm, and memorable.",
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // 5️⃣ CUSTOMISATION
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 260),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Customize Your Product",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Create personalised gifts that tell your story.",
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllCategoriesPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text("Customise"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // 6️⃣ STAMP / LOYALTY
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 320),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: const Text(
                  "Stamp 10 / 30  •  Collect Rewards",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 7️⃣ LOOKBOOK / MOOD STRIP
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 380),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "The Sirelle Mood",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            final product = shuffled[index];
                            return GestureDetector(
                              onTap: () {
                                RecommendationEngine.trackProductView(product);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsPage(product: product),
                                  ),
                                );
                              },
                              child: Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(26),
                                  child: Image.asset(
                                    product.thumbnail,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 8️⃣ EDITORIAL QUOTE BLOCK
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 440),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFEDF3), Color(0xFFFFFFFF)],
                      ),
                    ),
                    child: const Text(
                      "“Every piece at The Sirelle Co is designed to be felt, not just owned.”",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 9️⃣ CUSTOMER LOVE STRIP
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 500),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Loved by You",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          children: [
                            _testimonialCard("So aesthetic and premium ✨"),
                            _testimonialCard("Perfect gifting option 💗"),
                            _testimonialCard("Looks even better in real life"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          // 🔒 BRAND SEAL — LOGO END CAP (VISUAL ONLY)
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 560),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    height: 128,
                    width: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          Colors.pink.shade50,
                          Colors.pink.shade100.withOpacity(0.6),
                        ],
                        radius: 0.85,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.22),
                          blurRadius: 26,
                          spreadRadius: 6,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        height: 86,
                        width: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            "assets/logo/logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "The Sirelle Co",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Thoughtfully made · Loved deeply",
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.4,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------ EXPLORE ALL MODELS & HELPERS ------------------------

class _ExploreItem {
  final String name;
  final String categoryKey;
  const _ExploreItem(this.name, this.categoryKey);
}

const List<_ExploreItem> _exploreItems = [
  _ExploreItem("Cute Bottles", "bottles"),
  _ExploreItem("Aesthetic Candles", "candle"),
  _ExploreItem("Custom Caps", "caps"),
  _ExploreItem("Plush Toys", "plusie"),
  _ExploreItem("Keychains", "key_chain"),
];

Widget _exploreText(String name, {required bool imageLeft}) {
  String subtitle;
  switch (name) {
    case "Cute Bottles":
      subtitle = "Pretty bottles for everyday hydration with stylish touch.";
      break;
    case "Aesthetic Candles":
      subtitle = "Soft candles that bring warmth and a cozy feeling to space.";
      break;
    case "Custom Caps":
      subtitle = "Custom caps made to match personal style with ease.";
      break;
    case "Plush Toys":
      subtitle = "Soft plush toys perfect for gifting and warm moments.";
      break;
    case "Keychains":
      subtitle = "Cute keychains that add a charming touch to essentials.";
      break;
    default:
      subtitle = "Hand‑picked just for you";
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Side-aware aligned heading that hugs the image side
      Padding(
        padding: imageLeft
            ? const EdgeInsets.only(left: 6, right: 18)
            : const EdgeInsets.only(left: 18, right: 6),
        child: Align(
          alignment: imageLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              name,
              textAlign: imageLeft ? TextAlign.left : TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: Color(0xFF2B2B2B),
              ),
            ),
          ),
        ),
      ),

      const SizedBox(height: 6),

      // Darker professional description (no box), left/right aligned with padding
      Padding(
        padding: imageLeft
            ? const EdgeInsets.only(left: 6, right: 18)
            : const EdgeInsets.only(left: 18, right: 6),
        child: Text(
          subtitle,
          textAlign: imageLeft ? TextAlign.left : TextAlign.right,
          style: const TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Color(0xFF222222),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      const SizedBox(height: 6),
      const SizedBox(
        width: 90,
        child: Divider(
          thickness: 1,
          color: Color(0xFFDDDDDD),
        ),
      ),
    ],
  );
}

class _CategoryChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final String categoryKey;

  const _CategoryChip(this.title, this.icon, this.categoryKey);

  @override
  Widget build(BuildContext context) {
    final Product p = getThemedProduct(categoryKey);

    return GestureDetector(
      onTap: () {
        RecommendationEngine.trackCategoryClick(categoryKey);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AllCategoriesPage(initialCategory: categoryKey),
          ),
        );
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  p.thumbnail,
                  fit: BoxFit.cover,
                ),
              ),
              // soft dark overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // category label
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B2B2B),
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

// Helper widget for testimonial cards
Widget _testimonialCard(String text) {
  return Container(
    width: 220,
    margin: const EdgeInsets.only(right: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.45, letterSpacing: 0.1),
    ),
  );
}

// Occasion Card helper widget
class _OccasionCard extends StatelessWidget {
  final String title;
  const _OccasionCard(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// Scroll-in fade/slide animation for sections
class _ScrollFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _ScrollFadeIn({required this.child, this.delay = Duration.zero});

  @override
  State<_ScrollFadeIn> createState() => _ScrollFadeInState();
}

class _ScrollFadeInState extends State<_ScrollFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

Product getThemedProduct(String categoryKey) {
  final month = DateTime.now().month;
  final bool festive = (month == 10 || month == 11);
  final bool valentine = (month == 2);

  List<Product> filtered = products.where((p) {
    if (!p.thumbnail.contains(categoryKey)) return false;

    if (festive) {
      return p.thumbnail.toLowerCase().contains("festive");
    }

    if (valentine) {
      return p.thumbnail.toLowerCase().contains("valentine");
    }

    return true; // normal / fallback
  }).toList();

  if (filtered.isEmpty) {
    filtered = products
        .where((p) => p.thumbnail.contains(categoryKey))
        .toList();
  }

  filtered.shuffle();
  return filtered.isNotEmpty ? filtered.first : products.first;
}

Widget _exploreImageFromCategory(BuildContext context, String categoryKey) {
  final Product p = getThemedProduct(categoryKey);

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AllCategoriesPage(initialCategory: categoryKey),
        ),
      );
    },
    child: Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFFEEF3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(p.thumbnail, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.black.withOpacity(0.10),
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

// 🧱 Letter side frame (helper widget)
Widget _sideFrame(String imagePath) {
  return Container(
    width: 540,
    height: 440,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(240), // soft arch radius base
      boxShadow: [
        // Soft lift (depth)
        BoxShadow(
          color: Colors.black.withOpacity(0.14),
          blurRadius: 22,
          offset: const Offset(0, 14),
        ),
        // Subtle ambient shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        // Gentle pink glow (halo, not neon)
        BoxShadow(
          color: const Color(0xFFFFB6CF).withOpacity(0.28),
          blurRadius: 28,
          spreadRadius: -4,
          offset: const Offset(0, 0),
        ),
      ],
    ),
    child: ClipPath(
      clipper: _ArchClipper(),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // glass highlight
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.14),
                    Colors.transparent,
                    Colors.black.withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start bottom-left
    path.moveTo(0, size.height);

    // Left side straight up
    path.lineTo(0, size.height * 0.28);

    // Smooth rounded arch
    path.cubicTo(
      size.width * 0.08,
      0,
      size.width * 0.92,
      0,
      size.width,
      size.height * 0.28,
    );

    // Right side straight down
    path.lineTo(size.width, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class _BeverageAdSection extends StatelessWidget {
  const _BeverageAdSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEF3),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Heading
            _sectionHeader(context, "Letters"),
            const SizedBox(height: 14),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 18, 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AllCategoriesPage(
                                  initialCategory: "letter",
                                ),
                              ),
                            );
                          },
                          child: _sideFrame(getThemedProduct("letter").thumbnail),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Transform.translate(
                            offset: const Offset(18, 0), // move boxes further RIGHT
                            child: SizedBox(
                              height: 480,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _Badge(
                                    icon: Icons.favorite,
                                    label: "Loved",
                                    imagePath: getThemedProduct("letter").thumbnail,
                                  ),
                                  const SizedBox(height: 25),
                                  _Badge(
                                    icon: Icons.card_giftcard,
                                    label: "Giftable",
                                    imagePath: getThemedProduct("letter").thumbnail,
                                  ),
                                  const SizedBox(height: 25),
                                  _Badge(
                                    icon: Icons.auto_awesome,
                                    label: "Premium",
                                    imagePath: getThemedProduct("letter").thumbnail,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String imagePath;

  const _Badge({
    required this.icon,
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),

          // Light pink gradient overlay (images are clear and detailed)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFC1D9).withOpacity(0.48),
                    const Color(0xFFFFC1D9).withOpacity(0.70),
                  ],
                ),
              ),
            ),
          ),

          // Icon + label (unchanged visual identity)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFFB2004D), size: 30),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFB2004D),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}