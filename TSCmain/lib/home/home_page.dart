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

  /// Controller for auto scrolling ribbon
  final ScrollController _scrollController = ScrollController();

  /// Tabs/pages (initialized in initState so we can pass callbacks)
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    // Build the tab pages, including callback for AllCategories
    screens = [
      const AnimatedHomeTab(), // 👈 NEW animated home tab
      const Center(child: Text("Favourite Page")),
      AllCategoriesPage(
        onBackToHome: () {
          // 👈 This is what the back button in AllCategories will call
          if (!mounted) return;
          setState(() {
            selectedIndex = 0;
          });
        },
      ),
      const CartPage(),
      const ProfilePage(),
    ];

    /// Kept for future use (not actually driving ribbon now)
    _marqueeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    /// Start auto scrolling the ribbon
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  /// Auto-scroll smooth movement for the offer ribbon
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
                /// ⭐ HOME page only: offer ribbon + curved top bar
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

                /// Content of the selected tab
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
      height: 48,
      child: Listener(
        // 👇 allows horizontal drag to manually scroll ribbon
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
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
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
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

/// ===================================================================
/// ⭐ ANIMATED HOME TAB – aesthetic + interactive + animated
/// ===================================================================
class AnimatedHomeTab extends StatefulWidget {
  const AnimatedHomeTab({super.key});

  @override
  State<AnimatedHomeTab> createState() => _AnimatedHomeTabState();
}

class _AnimatedHomeTabState extends State<AnimatedHomeTab>
    with SingleTickerProviderStateMixin {
  late final PageController _bannerController;
  int _currentBanner = 0;

  int _selectedCategory = 0;

  late final AnimationController _introAnimController;

  final List<String> _categories = [
    "Jeans",
    "Tops",
    "Dresses",
    "Shoes",
    "Bags",
    "Accessories",
  ];

  final List<Map<String, dynamic>> _recommended = [
    {
      "title": "Summer Denim",
      "subtitle": "Soft high-rise fit",
      "price": "₹1,299",
      "badge": "New",
    },
    {
      "title": "Pastel Hoodie",
      "subtitle": "Oversized & cozy",
      "price": "₹1,899",
      "badge": "Trending",
    },
    {
      "title": "Everyday Sneakers",
      "subtitle": "Cloud-soft sole",
      "price": "₹2,499",
      "badge": "Best Seller",
    },
    {
      "title": "Mini Shoulder Bag",
      "subtitle": "Perfect for brunch",
      "price": "₹999",
      "badge": "Hot",
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 0.9);
    _introAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _bannerController.addListener(() {
      final page = _bannerController.page ?? 0;
      final index = page.round();
      if (index != _currentBanner && index >= 0 && index < 3) {
        setState(() => _currentBanner = index);
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _introAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: const Color(0xFFFCEEEE),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(theme),
              const SizedBox(height: 12),
              _buildBannerCarousel(),
              const SizedBox(height: 18),
              _buildCategoryRow(theme),
              const SizedBox(height: 20),
              _buildSectionHeader("For you", "Handpicked looks"),
              const SizedBox(height: 12),
              _buildRecommendedGrid(theme),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Greeting / intro with subtle slide+fade
  // ---------------------------------------------------------------
  Widget _buildGreeting(ThemeData theme) {
    return AnimatedBuilder(
      animation: _introAnimController,
      builder: (context, child) {
        final value = Curves.easeOut.transform(_introAnimController.value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hey there 👋",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.pink.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Let’s style your day in pastel vibes.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.pink.shade900.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Hero banner carousel with subtle scaling + dots
  // ---------------------------------------------------------------
  Widget _buildBannerCarousel() {
    final banners = [
      {
        "title": "New Pastel Drop",
        "subtitle": "Soft tones • Premium feel",
        "cta": "Shop collection",
        "emoji": "🌸"
      },
      {
        "title": "Denim Days",
        "subtitle": "Comfy fits for daily wear",
        "cta": "Explore denim",
        "emoji": "👖"
      },
      {
        "title": "Members Only",
        "subtitle": "Extra 5% off for you",
        "cta": "Unlock perks",
        "emoji": "💎"
      },
    ];

    return SizedBox(
      height: 170,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _bannerController,
              itemCount: banners.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final data = banners[index];
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 350),
                  tween: Tween<double>(
                    begin: 0.92,
                    end: index == _currentBanner ? 1.0 : 0.92,
                  ),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [
                          Colors.pinkAccent.withOpacity(0.85),
                          Colors.white.withOpacity(0.95),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -10,
                          top: -10,
                          child: Opacity(
                            opacity: 0.25,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.7),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      data["title"] as String,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      data["subtitle"] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            Colors.white.withOpacity(0.92),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color:
                                            Colors.white.withOpacity(0.92),
                                      ),
                                      child: Text(
                                        data["cta"] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.pink.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data["emoji"] as String,
                                style: const TextStyle(
                                  fontSize: 40,
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: index == _currentBanner ? 18 : 7,
                decoration: BoxDecoration(
                  color: index == _currentBanner
                      ? Colors.pinkAccent
                      : Colors.pinkAccent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Story-like category bubbles with tap bounce
  // ---------------------------------------------------------------
  Widget _buildCategoryRow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Shop by vibe", "Pick your mood"),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedCategory;
              final label = _categories[index];

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = index);
                  // 👉 You can trigger navigation / filtering here
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.06 : 1.0,
                        duration: const Duration(milliseconds: 190),
                        curve: Curves.easeOut,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isSelected
                                  ? [
                                      Colors.pinkAccent.withOpacity(0.95),
                                      Colors.white.withOpacity(0.95),
                                    ]
                                  : [
                                      Colors.white.withOpacity(0.96),
                                      Colors.pinkAccent.withOpacity(0.15),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.pinkAccent.withOpacity(0.4),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.pinkAccent
                                          .withOpacity(0.12),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          child: Center(
                            // Placeholder icon – replace with product image later
                            child: Icon(
                              Icons.favorite_rounded,
                              size: 24,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.pink.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.pink.shade900
                              : Colors.pink.shade900.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Section header (title + subtitle)
  // ---------------------------------------------------------------
  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.pink.shade900,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.pink.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Recommended products grid with subtle entrance animation
  // ---------------------------------------------------------------
  Widget _buildRecommendedGrid(ThemeData theme) {
    return GridView.builder(
      itemCount: _recommended.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 210,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = _recommended[index];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 280 + (index * 90)),
          tween: Tween<double>(begin: 0.85, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: value,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: () {
              // 👉 Hook for navigation to product details
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.98),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Image / placeholder area
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        // 🔁 Replace this later with your Network / Asset image
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.pink.shade200,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBadge(item["badge"] as String),
                        const SizedBox(height: 4),
                        Text(
                          item["title"] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.pink.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item["subtitle"] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.pink.shade900.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item["price"] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.pink.shade800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.pinkAccent.withOpacity(0.12),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: Colors.pink.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            Colors.pinkAccent.withOpacity(0.9),
            Colors.pinkAccent.withOpacity(0.6),
          ],
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}