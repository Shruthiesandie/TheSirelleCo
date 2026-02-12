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
import '../widgets/pull_to_refresh_lottie.dart';

import '../services/product_service.dart';
import '../models/product.dart';
import '../controllers/favorites_controller.dart';
import '../services/behavior_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;
  bool isGuest = false;
  int _homeRefreshKey = 0;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args["guest"] == true) {
      isGuest = true;
    }
  }

  late final AnimationController _marqueeController;
  final ScrollController _scrollController = ScrollController();

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    // 🔥 AI Behavior Log — Home page opened
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      BehaviorLogger.log(
        userId: user.uid,
        screenName: "home_page",
        actionType: "navigation",
        actionValue: "open",
      );
    }

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
      drawer: HomeDrawer(
        isGuest: isGuest,
        onProfileTap: () {
          setState(() {
            selectedIndex = 4; // Profile tab index
          });
        },
      ),
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
                        ? _HomeContent(
                            key: ValueKey(_homeRefreshKey),
                            onForceRemount: () {
                              setState(() {
                                _homeRefreshKey++;
                              });
                            },
                          )
                        : IndexedStack(index: selectedIndex, children: screens),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNavBar(
                selectedIndex: selectedIndex,
                onItemTap: (index) {
                  // 🔥 AI Behavior Log — bottom navigation tap
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    BehaviorLogger.log(
                      userId: user.uid,
                      screenName: "home_page",
                      actionType: "navigation",
                      actionValue: "tab_" + index.toString(),
                    );
                  }

                  setState(() => selectedIndex = index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ ENHANCED PREMIUM RIBBON WITH ELASTIC ANIMATIONS
  Widget _premiumOfferRibbon() {
    List<String> offers = [
      "💗 Flat 10% OFF on ₹1000+ orders",
      "✨ 20% OFF on ₹4000+ purchases",
      "⭐ Members get extra 5% cashback",
      "🚚 Free Delivery on prepaid orders",
    ];

    return SizedBox(
      height: 46,
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
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 9999,
              itemBuilder: (_, i) {
                String offer = offers[i % offers.length];
<<<<<<< Updated upstream

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
                        const Color.fromARGB(
                          255,
                          250,
                          32,
                          105,
                        ).withOpacity(0.17),
                        Colors.white.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          203,
                          9,
                          74,
                        ).withOpacity(0.15),
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
                      color: const Color.fromARGB(255, 98, 2, 53),
                    ),
                  ),
=======
                
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            colors: [
                              Colors.pinkAccent.withOpacity(0.2),
                              Colors.white.withOpacity(0.95),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          offer,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.pink.shade900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    );
                  },
>>>>>>> Stashed changes
                );
              },
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFFFCEEEE),
                        const Color(0xFFFCEEEE).withOpacity(0.0),
                        const Color(0xFFFCEEEE).withOpacity(0.0),
                        const Color(0xFFFCEEEE),
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

// ------------------------ ENHANCED SECTION HEADER ------------------------
Widget _sectionHeader(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      children: [
        const Expanded(
          child: Divider(thickness: 2.0, color: Color(0xFF5F6F52)),
        ),
        const SizedBox(width: 14),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE4EC), Color(0xFFFFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
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
            );
          },
        ),
        const SizedBox(width: 14),
        const Expanded(
<<<<<<< Updated upstream
          child: Divider(thickness: 2.0, color: Color(0xFF5F6F52)),
=======
          child: Divider(thickness: 1.2, color: Color(0xFFf3c6d4)),
>>>>>>> Stashed changes
        ),
      ],
    ),
  );
}

class _HomeContent extends StatefulWidget {
  final VoidCallback? onForceRemount;
  const _HomeContent({Key? key, this.onForceRemount}) : super(key: key);

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> with SingleTickerProviderStateMixin {
  List<Product> _products = [];
  bool _loading = true;
  int _refreshSeed = 0;
  double _refreshOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
      final fetched = await ProductService.fetchProducts();
      if (!mounted) return;

      setState(() {
        final list = List<Product>.from(fetched);
        list.shuffle(); // 🔥 reshuffle products every refresh
        _refreshSeed++;
        _products = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Product _pickRotated(int offset) {
    if (_products.isEmpty) throw StateError('No products available');
    return _products[(_refreshSeed + offset) % _products.length];
  }

  Widget _exploreImageFromCategory(BuildContext context, String categoryKey) {
    if (_products.isEmpty) return const SizedBox.shrink();

    final Product p = _products.firstWhere(
      (p) => p.category == categoryKey && p.imageUrl.isNotEmpty,
      orElse: () => _pickRotated(1),
    );

    return _MajesticCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AllCategoriesPage(initialCategory: categoryKey),
          ),
        );
      },
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            p.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFFFE3EC),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.pinkAccent,
                  size: 28,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _products.isEmpty) {
      return const _MajesticLoadingShimmer();
    }
    
    final List<Product> shuffled = _products;
    final month = DateTime.now().month;
    final bool festive = (month == 10 || month == 11);
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

    return PullToRefreshLottie(
      onRefresh: () async {
        if (!mounted) return;

        // ✨ Fade out current UI smoothly
        setState(() {
          _refreshOpacity = 0.0;
        });

        await Future.delayed(const Duration(milliseconds: 250));

        // 🔥 Clear products before fetching fresh backend data
        setState(() {
          _products.clear();
          _loading = true;
        });

        // Fetch latest products
        await _loadProducts();

        // ✨ Fade UI back in for luxury feel
        if (mounted) {
          setState(() {
            _refreshOpacity = 1.0;
          });
        }
      },
      child: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            opacity: _refreshOpacity,
            child: ListView(
              primary: true,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // 1️⃣ ENHANCED HERO WITH PARALLAX
                    _ScrollFadeIn(
                      delay: Duration.zero,
                      child: _HeroBanner(
                        key: ValueKey('hero_$_refreshSeed'),
                        products: shuffled,
                        pickRotated: _pickRotated,
                        heroGradient: heroGradient,
                        heroTag: heroTag,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2️⃣ ENHANCED CATEGORIES
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 80),
                      child: _EnhancedCategorySection(
                        key: ValueKey('cat_$_refreshSeed'),
                        products: _products,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3️⃣ ENHANCED EXPLORE
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 120),
                      child: _EnhancedExploreSection(
                        products: _products,
                        exploreImageBuilder: _exploreImageFromCategory,
                      ),
                    ),

                    // 4️⃣ ENHANCED GIFT HAMPER
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 160),
                      child: _EnhancedGiftHamper(
                        products: _products,
                        pickRotated: _pickRotated,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 5️⃣ ENHANCED TRENDING GRID
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: _EnhancedTrendingSection(
                        key: ValueKey('trend_$_refreshSeed'),
                        products: shuffled,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // 6️⃣ JUST DROPPED
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 240),
                      child: _EnhancedJustDroppedSection(products: shuffled),
                    ),

                    const SizedBox(height: 36),

                    // 7️⃣ GIFTING MOMENTS
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 280),
                      child: _GiftingMomentsSection(),
                    ),

                    // 8️⃣ SHOP BY OCCASION
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 320),
                      child: _EnhancedOccasionSection(),
                    ),

                    // 9️⃣ BRAND STORY
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 360),
                      child: _EnhancedBrandStorySection(),
                    ),

                    const SizedBox(height: 36),

                    // 🔟 CUSTOMIZATION
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 400),
                      child: _EnhancedCustomizationSection(),
                    ),

                    const SizedBox(height: 36),

                    // 1️⃣1️⃣ LOYALTY
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 440),
                      child: _EnhancedLoyaltySection(),
                    ),

                    // 1️⃣2️⃣ MOOD
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 480),
                      child: _EnhancedMoodSection(products: shuffled),
                    ),

                    // 1️⃣3️⃣ EDITORIAL
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 520),
                      child: _EnhancedEditorialSection(),
                    ),

                    // 1️⃣4️⃣ TESTIMONIALS
                    _ScrollFadeIn(
                      delay: const Duration(milliseconds: 560),
                      child: _EnhancedTestimonialsSection(),
                    ),

                    const SizedBox(height: 60),

                    // 1️⃣5️⃣ MAJESTIC ENDING WITH STAMP
                    _MajesticBrandEnding(
                      products: _products,
                      pickRotated: _pickRotated,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------ MAJESTIC 3D TILT CARD ------------------------
class _MajesticCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  
  const _MajesticCard({required this.child, required this.onTap});

<<<<<<< Updated upstream
          // 🔍 EXPLORE ALL — CATEGORY STORY STRIP
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 110),
            child: ClipPath(
              clipper: _TopAndBottomWaveClipper(),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color.fromARGB(255, 125, 5, 53), Color.fromARGB(255, 192, 12, 87)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
=======
  @override
  State<_MajesticCard> createState() => _MajesticCardState();
}

class _MajesticCardState extends State<_MajesticCard> with SingleTickerProviderStateMixin {
  double x = 0;
  double y = 0;
  double scale = 1.0;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.95),
      onTapUp: (_) {
        setState(() => scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => scale = 1.0),
      onPanUpdate: (details) {
        setState(() {
          y = details.delta.dx * 0.01;
          x = details.delta.dy * -0.01;
        });
      },
      onPanEnd: (_) => setState(() { x = 0; y = 0; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(x)
          ..rotateY(y)
          ..scale(scale),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

// ------------------------ ENHANCED HERO BANNER ------------------------
class _HeroBanner extends StatelessWidget {
  final List<Product> products;
  final Product Function(int) pickRotated;
  final LinearGradient heroGradient;
  final String heroTag;

  const _HeroBanner({
    super.key,
    required this.products,
    required this.pickRotated,
    required this.heroGradient,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (products.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: pickRotated(0)),
          ),
        );
      },
      child: Hero(
        tag: 'hero_banner',
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 420,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: heroGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Parallax Image Effect
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 1.05),
                  duration: const Duration(seconds: 10),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: products.isEmpty
                          ? Container(
                              color: const Color(0xFFFFE3EC),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.pinkAccent,
                                size: 50,
                              ),
                            )
                          : Image.asset(
                              pickRotated(0).imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    );
                  },
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Content
                Positioned(
                  left: 24,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          heroTag,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB2004D),
                          ),
                        ),
                      ),
                    ],
>>>>>>> Stashed changes
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
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
                                _exploreImageFromCategory(
                                  context,
                                  item.categoryKey,
                                ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _exploreText(
                                  item.name,
                                  imageLeft: imageLeft,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (!imageLeft)
                                _exploreImageFromCategory(
                                  context,
                                  item.categoryKey,
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

<<<<<<< Updated upstream
          // (Pink section above Gift Hamper header removed)
          _sectionHeader(context, "Gift Hamper"),
          const SizedBox(height: 36),
          // 🎁 CUSTOM GIFT HAMPER FEATURE (from sketch)
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 130),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 210, 210),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
=======
// ------------------------ ENHANCED CATEGORY SECTION ------------------------
class _EnhancedCategorySection extends StatelessWidget {
  final List<Product> products;
  const _EnhancedCategorySection({super.key, required this.products});

  final List<Map<String, dynamic>> categories = const [
    {"name": "Bottles", "icon": Icons.local_drink, "key": "Bottle"},
    {"name": "Candles", "icon": Icons.local_fire_department, "key": "Candle"},
    {"name": "Caps", "icon": Icons.checkroom, "key": "Cap"},
    {"name": "Ceramic", "icon": Icons.coffee, "key": "Ceramic"},
    {"name": "Hair", "icon": Icons.face, "key": "Hair"},
    {"name": "Keychains", "icon": Icons.key, "key": "Keychain"},
    {"name": "Letters", "icon": Icons.text_fields, "key": "Letter"},
    {"name": "Nails", "icon": Icons.brush, "key": "Nails"},
    {"name": "Plushies", "icon": Icons.toys, "key": "Plush"},
    {"name": "Boy Friend", "icon": Icons.favorite, "key": "BoyFriend"},
    {"name": "Girl Friend", "icon": Icons.favorite_border, "key": "GirlFriend"},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _EnhancedCategoryChip(
            title: cat["name"],
            icon: cat["icon"],
            categoryKey: cat["key"],
            products: products,
            index: index,
          );
        },
      ),
    );
  }
}

class _EnhancedCategoryChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final String categoryKey;
  final List<Product> products;
  final int index;

  const _EnhancedCategoryChip({
    required this.title,
    required this.icon,
    required this.categoryKey,
    required this.products,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Product? matchedProduct;
    if (products.isNotEmpty) {
      try {
        matchedProduct = products.firstWhere(
          (p) => p.category == categoryKey && p.imageUrl.isNotEmpty,
          orElse: () => products.first,
        );
      } catch (e) {
        matchedProduct = null;
      }
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllCategoriesPage(initialCategory: categoryKey),
>>>>>>> Stashed changes
                ),
              );
            },
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  children: [
<<<<<<< Updated upstream
                    // Right semicircle bubble (true semicircle using ClipOval)
                    Positioned(
                      right: -140,
                      top: 25,
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
=======
                    Positioned.fill(
                      child: matchedProduct == null
                          ? Container(color: const Color(0xFFFFE3EC))
                          : Image.asset(matchedProduct.imageUrl, fit: BoxFit.cover),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
>>>>>>> Stashed changes
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2B2B2B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

<<<<<<< Updated upstream
          const SizedBox(height:0),

          _ScrollFadeIn(
            delay: const Duration(milliseconds: 150),
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFFFEEF3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFB2004D).withOpacity(0.18),
                        blurRadius: 30,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🌸 Soft pill label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE4EC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "GIFTING FEATURE",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Color(0xFFB2004D),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ✨ Headline
                      const Text(
                        "Build Your Own Gift Hamper",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                          color: Color.fromARGB(255, 183, 15, 35),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🌷 Description
                      const Text(
                        "Mix and match products across all categories to create a personalised gift hamper. Thoughtful, custom, and made to feel truly special.",
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 💗 Micro highlights
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: const [
                          _HamperHighlight("🎁", "Personalised"),
                          _HamperHighlight("💌", "Thoughtful"),
                          _HamperHighlight("✨", "Unique"),
                        ],
                      ),
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
                    // Optional: Clear previous hamper state for fresh start
                    // HamperBuilderController.clear();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllCategoriesPage(isHamperMode: true),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFB2004D),
                          Color(0xFFD81B60),
                          Color(0xFFFF9EBF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB2004D).withOpacity(0.45),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Customize",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 0),
          const SizedBox(height: 40),
          _BeverageAdSection(),
          const SizedBox(height: 40),
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 40),
=======
// ------------------------ ENHANCED EXPLORE SECTION ------------------------
class _EnhancedExploreSection extends StatelessWidget {
  final List<Product> products;
  final Widget Function(BuildContext, String) exploreImageBuilder;

  const _EnhancedExploreSection({
    required this.products,
    required this.exploreImageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sectionHeader(context, "Explore All"),
        const SizedBox(height: 20),
        Column(
          children: [
            _ExploreRowItem(
              name: "Cute Bottles",
              subtitle: "Pretty bottles for everyday hydration with stylish touch.",
              categoryKey: "Bottle",
              imageLeft: true,
              exploreImageBuilder: exploreImageBuilder,
              delay: 0,
            ),
            _ExploreRowItem(
              name: "Aesthetic Candles",
              subtitle: "Soft candles that bring warmth and a cozy feeling to space.",
              categoryKey: "Candle",
              imageLeft: false,
              exploreImageBuilder: exploreImageBuilder,
              delay: 100,
            ),
            _ExploreRowItem(
              name: "Custom Caps",
              subtitle: "Custom caps made to match personal style with ease.",
              categoryKey: "Cap",
              imageLeft: true,
              exploreImageBuilder: exploreImageBuilder,
              delay: 200,
            ),
            _ExploreRowItem(
              name: "Plush Toys",
              subtitle: "Soft plush toys perfect for gifting and warm moments.",
              categoryKey: "Plush",
              imageLeft: false,
              exploreImageBuilder: exploreImageBuilder,
              delay: 300,
            ),
          ],
        ),
        const SizedBox(height: 30),
        _sectionHeader(context, "Gift Hamper"),
      ],
    );
  }
}

class _ExploreRowItem extends StatelessWidget {
  final String name;
  final String subtitle;
  final String categoryKey;
  final bool imageLeft;
  final Widget Function(BuildContext, String) exploreImageBuilder;
  final int delay;

  const _ExploreRowItem({
    required this.name,
    required this.subtitle,
    required this.categoryKey,
    required this.imageLeft,
    required this.exploreImageBuilder,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 50.0, end: 0.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(imageLeft ? -offset : offset, 0),
          child: Opacity(
            opacity: (50 - offset.abs()) / 50,
>>>>>>> Stashed changes
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (imageLeft) exploreImageBuilder(context, categoryKey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: imageLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB2004D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: imageLeft 
                              ? const EdgeInsets.only(right: 20) 
                              : const EdgeInsets.only(left: 20),
                          child: Text(
                            subtitle,
                            textAlign: imageLeft ? TextAlign.left : TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!imageLeft) exploreImageBuilder(context, categoryKey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------------ ENHANCED GIFT HAMPER ------------------------
class _EnhancedGiftHamper extends StatelessWidget {
  final List<Product> products;
  final Product Function(int) pickRotated;

  const _EnhancedGiftHamper({
    required this.products,
    required this.pickRotated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF1F4), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                  child: Container(
                    height: 280,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE3EC),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          right: -100,
                          top: -50,
                          child: Container(
                            width: 350,
                            height: 350,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.pink.shade100.withOpacity(0.4),
                            ),
                          ),
                        ),
                        Hero(
                          tag: 'hamper_image',
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: products.isEmpty
                                  ? Container(color: Colors.white)
                                  : Image.asset(
                                      pickRotated(2).imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4EC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Gift Hamper",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB2004D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Introducing Gift Hampers",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB2004D),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Create your own personalised gift hamper by mixing and matching products from every category. A perfect way to make your gift feel special and thoughtful.",
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _MajesticButton(
                        text: "Customize",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AllCategoriesPage(isHamperMode: true),
                            ),
                          );
                        },
                      ),
                    ],
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

// ------------------------ ENHANCED TRENDING SECTION ------------------------
class _EnhancedTrendingSection extends StatelessWidget {
  final List<Product> products;
  const _EnhancedTrendingSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sectionHeader(context, "Trending Right Now"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length >= 6 ? 6 : products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              if (index >= products.length) return const SizedBox.shrink();
              final product = products[index];
              return _TrendingProductCard(
                product: product,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TrendingProductCard extends StatefulWidget {
  final Product product;
  final int index;

  const _TrendingProductCard({
    required this.product,
    required this.index,
  });

  @override
  State<_TrendingProductCard> createState() => _TrendingProductCardState();
}

class _TrendingProductCardState extends State<_TrendingProductCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTapDown: (_) => setState(() => isPressed = true),
              onTapUp: (_) {
                setState(() => isPressed = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsPage(product: widget.product),
                  ),
                );
              },
              onTapCancel: () => setState(() => isPressed = false),
              child: AnimatedScale(
                scale: isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                          child: Stack(
                            children: [
                              Image.asset(
                                widget.product.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: _AnimatedFavoriteButton(product: widget.product),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2B2B2B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "₹${widget.product.price}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB2004D),
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
          ),
        );
      },
    );
  }
}

// ------------------------ ANIMATED FAVORITE BUTTON ------------------------
class _AnimatedFavoriteButton extends StatefulWidget {
  final Product product;
  const _AnimatedFavoriteButton({required this.product});

  @override
  State<_AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<_AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: FavoritesController.items,
      builder: (context, _, __) {
        final isFav = FavoritesController.contains(widget.product);
        if (isFav) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
        
        return GestureDetector(
          onTap: () => FavoritesController.toggle(widget.product),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------------ ENHANCED JUST DROPPED ------------------------
class _EnhancedJustDroppedSection extends StatelessWidget {
  final List<Product> products;
  const _EnhancedJustDroppedSection({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sectionHeader(context, "Just Dropped"),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length >= 8 ? 8 : products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 16),
                child: _MajesticCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(product: product),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                            child: Image.asset(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ------------------------ OTHER ENHANCED SECTIONS ------------------------
class _GiftingMomentsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Gifting Moments",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB2004D),
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Birthdays, surprises, self‑love or just because — find something meaningful.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedOccasionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final occasions = ["Birthday Gifts", "Anniversary", "Self Care", "Cute Surprises"];
    
    return Column(
      children: [
        _sectionHeader(context, "Shop by Occasion"),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: occasions.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 100)),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          occasions[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB2004D),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EnhancedBrandStorySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF1F6), Color(0xFFFFFFFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "It's Official — The Sirelle Co",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB2004D),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, color: Color(0xFFB2004D), size: 20),
                Icon(Icons.star, color: Color(0xFFB2004D), size: 20),
                Icon(Icons.star, color: Color(0xFFB2004D), size: 20),
                Icon(Icons.star, color: Color(0xFFB2004D), size: 20),
                Icon(Icons.star_half, color: Color(0xFFB2004D), size: 20),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Thoughtfully crafted pieces designed to feel personal, warm, and memorable.",
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnhancedCustomizationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customize Your Product",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB2004D),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Create personalised gifts that tell your story.",
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 20),
            _MajesticButton(
              text: "Start Customizing",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllCategoriesPage(isHamperMode: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MajesticButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  
  const _MajesticButton({required this.text, required this.onTap});

  @override
  State<_MajesticButton> createState() => _MajesticButtonState();
}

class _MajesticButtonState extends State<_MajesticButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(isPressed ? 0.95 : 1.0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB2004D), Color(0xFFD81B60)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB2004D).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _EnhancedLoyaltySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.stars, color: Color(0xFFB2004D)),
            SizedBox(width: 12),
            Text(
              "Stamp 10 / 30  •  Collect Rewards",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFFB2004D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnhancedMoodSection extends StatelessWidget {
  final List<Product> products;
  const _EnhancedMoodSection({required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "The Sirelle Mood",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB2004D),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: products.length >= 6 ? 6 : products.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      products[index].imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedEditorialSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFEDF3), Color(0xFFFFFFFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
            ),
          ],
        ),
        child: const Text(
          "“Every piece at The Sirelle Co is designed to be felt, not just owned.”",
          style: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            height: 1.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFFB2004D),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _EnhancedTestimonialsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final testimonials = [
      "So aesthetic and premium ✨",
      "Perfect gifting option 💗",
      "Looks even better in real life",
      "Fast delivery and great packaging!",
      "Will definitely order again 🎁",
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Loved by You",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB2004D),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        testimonials[index],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
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
    );
  }
}

// ------------------------ MAJESTIC BRAND ENDING WITH STAMP ------------------------
class _MajesticBrandEnding extends StatelessWidget {
  final List<Product> products;
  final Product Function(int) pickRotated;

  const _MajesticBrandEnding({
    required this.products,
    required this.pickRotated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        
        // Animated Divider
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2),
          curve: Curves.easeOut,
          builder: (_, value, __) {
            return Opacity(
              opacity: value,
              child: Container(
                margin: const EdgeInsets.only(bottom: 30),
                height: 2,
                width: 140,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFC1D9), Color(0xFFB2004D)],
                  ),
                ),
              ),
            );
          },
        ),

        // Quote
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFEDF3), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Text(
              "Luxury isn't loud.\nIt's how something makes you feel.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB2004D),
              ),
            ),
          ),
        ),

        const SizedBox(height: 50),

        // STAMP SECTION - EXACTLY AS ORIGINAL BUT ENHANCED ANIMATIONS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                height: 2,
                width: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB2004D), Color(0xFFFFC1D9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "It's Official",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: Color(0xFF6A0030),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "The Sirelle Co",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Color(0xFFB2004D),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Thoughtfully curated · Made to feel personal",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 40),

              // Enhanced Stamp with rotation animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFE3EC),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        
                        // Decorative rings
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFC1D9),
                              width: 2,
                            ),
                          ),
                        ),

                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFB2004D),
                              width: 1,
                            ),
                          ),
                        ),

                        // Pulsing inner glow
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.2),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeInOut,
                          builder: (context, pulse, child) {
                            return Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFFC1D9).withOpacity(0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // ACTUAL STAMP IMAGE - PRESERVED EXACT PATH
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Image.asset(
                              "assets/stamp/stamp.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 50),

              Container(
                height: 2,
                width: 160,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC1D9), Color(0xFFB2004D)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

<<<<<<< Updated upstream
// ------------------------ TOP AND BOTTOM WAVE CLIPPER FOR EXPLORE ALL SECTION ------------------------
class _TopAndBottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // 🌊 Top wave (unchanged)
    path.lineTo(0, 24);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 16);
    path.quadraticBezierTo(size.width * 0.75, 32, size.width, 12);

    // Go down right side
    path.lineTo(size.width, size.height - 24);

    // 🌊 Bottom wave (same family curve)
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height,
      size.width * 0.5,
      size.height - 16,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 32,
      0,
      size.height - 12,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ------------------------ BOTTOM WAVE CLIPPER FOR GIFT HAMPER SECTION ------------------------

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
  _ExploreItem("Boy Friend Gifts", "boy_friend"),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE6F0E3), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9DB8A0).withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              name,
              textAlign: imageLeft ? TextAlign.left : TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: Color.fromARGB(255, 35, 52, 37),
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
            color: Color.fromARGB(255, 209, 208, 208),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      const SizedBox(height: 6),
      const SizedBox(
        width: 90,
        child: Divider(thickness: 1, color: Color(0xFF5F6F52)),
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
=======
        // Enhanced Dark Footer
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.fromLTRB(
            24,
            40,
            24,
            MediaQuery.of(context).padding.bottom + 100,
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            gradient: LinearGradient(
              colors: [Color(0xFFB2004D), Color(0xFFD81B60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
>>>>>>> Stashed changes
            children: [
              const Text(
                "Contact with Us",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Thoughtful gifts. Made with heart 💗",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              
              // Social Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FooterIcon(icon: Icons.facebook),
                  const SizedBox(width: 20),
                  _FooterIcon(icon: Icons.camera_alt),
                  const SizedBox(width: 20),
                  _FooterIcon(icon: Icons.telegram),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Unsubscribe anytime · No hard feelings 💕",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterIcon extends StatelessWidget {
  final IconData icon;
  const _FooterIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

// ------------------------ LOADING SHIMMER ------------------------
class _MajesticLoadingShimmer extends StatelessWidget {
  const _MajesticLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ],
    );
  }
}

// ------------------------ SCROLL FADE IN HELPER ------------------------
class _ScrollFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  
  const _ScrollFadeIn({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_ScrollFadeIn> createState() => _ScrollFadeInState();
}

class _ScrollFadeInState extends State<_ScrollFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
<<<<<<< Updated upstream
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
            Positioned.fill(child: Image.asset(p.thumbnail, fit: BoxFit.cover)),
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
          color: const Color.fromARGB(255, 249, 244, 199),
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
                          child: _sideFrame(
                            getThemedProduct("letter").thumbnail,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Transform.translate(
                            offset: const Offset(
                              18,
                              0,
                            ), // move boxes further RIGHT
                            child: SizedBox(
                              height: 480,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _Badge(
                                    icon: Icons.favorite,
                                    label: "Loved",
                                    imagePath: getThemedProduct(
                                      "letter",
                                    ).thumbnail,
                                  ),
                                  const SizedBox(height: 25),
                                  _Badge(
                                    icon: Icons.card_giftcard,
                                    label: "Giftable",
                                    imagePath: getThemedProduct(
                                      "letter",
                                    ).thumbnail,
                                  ),
                                  const SizedBox(height: 25),
                                  _Badge(
                                    icon: Icons.auto_awesome,
                                    label: "Premium",
                                    imagePath: getThemedProduct(
                                      "letter",
                                    ).thumbnail,
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover)),

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

// --- DARK PINK PREMIUM FOOTER HELPERS ---

class _FooterFeature extends StatelessWidget {
  final String emoji;
  final String text;

  const _FooterFeature(this.emoji, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13.5,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Premium glassy footer icon widget
class _PremiumFooterIcon extends StatelessWidget {
  final IconData icon;
  const _PremiumFooterIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.28),
            Colors.white.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, size: 30, color: Colors.white),
    );
  }
}

// --- Helper widget for gift hamper highlights ---
class _HamperHighlight extends StatelessWidget {
  final String emoji;
  final String label;
  const _HamperHighlight(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }
=======
>>>>>>> Stashed changes
}