// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

import '../controllers/favorites_controller.dart';
import '../controllers/hamper_builder_controller.dart';
import '../data/products.dart';
import 'product_details_page.dart';
import '../models/product.dart';
import '../services/recommendation_engine.dart';
import '../controllers/cart_controllers.dart';
import '../models/gift_hamper.dart';
import 'cart_page.dart';

class AllCategoriesPage extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final String? initialCategory;
  final bool isHamperMode;

  const AllCategoriesPage({
    super.key,
    this.onBackToHome,
    this.initialCategory,
    this.isHamperMode = false,
  });

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage>
    with SingleTickerProviderStateMixin {
  late List<String> _allCategoryCachedThumbs;
  bool showSearch = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();

  int selectedCategoryIndex = 0;
  String selectedCategory = "All";

  // Badge helper (randomized but stable per product)
  String? _badgeFor(product) {
    final r = product.id.hashCode % 5;
    if (r == 0) return "NEW";
    if (r == 1) return "-20%";
    if (r == 2) return "BESTSELLER";
    return null;
  }

  final List<String> categories = [
    "All",
    "bottles",
    "candle",
    "caps",
    "ceramic",
    "hair_accessories",
    "key_chain",
    "letter",
    "nails",
    "plusie",
    "boy_friend",
    "girl_friend",
  ];


  @override
  void initState() {
    super.initState();

    _allCategoryCachedThumbs = products
        .map((p) => p.thumbnail)
        .where((t) => t.isNotEmpty)
        .toList();
    _allCategoryCachedThumbs.shuffle(Random());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    if (widget.initialCategory != null) {
      final index = categories.indexWhere(
        (c) => c == widget.initialCategory,
      );

      if (index != -1) {
        selectedCategoryIndex = index;
        selectedCategory = categories[index];
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  String _categoryIcon(String category) {
    switch (category) {
      case "All":
        return "assets/icons/all.png";
      case "bottles":
        return "assets/icons/bottel.png";
      case "candle":
        return "assets/icons/candle.png";
      case "caps":
        return "assets/icons/caps.png";
      case "ceramic":
        return "assets/icons/ceramic.png";
      case "hair_accessories":
        return "assets/icons/hair_accessories.png";
      case "key_chain":
        return "assets/icons/key_chain.png";
      case "letter":
        return "assets/icons/letter.png";
      case "nails":
        return "assets/icons/nail.png";
      case "plusie":
        return "assets/icons/plusie.png";
      case "boy_friend":
        return "assets/icons/all.png";
      case "girl_friend":
        return "assets/icons/all.png";
      default:
        return "assets/icons/all.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> filteredProducts;

    // Recommendations: always exclude current product (if any), shuffle, and limit to 6
    final List<Product> recommended = List<Product>.from(products)
      ..shuffle();

    if (selectedCategory == "All") {
      // Randomized once per app launch (cached in initState)
      filteredProducts = _allCategoryCachedThumbs
          .map((thumb) =>
              products.firstWhere((p) => p.thumbnail == thumb))
          .toList();
    } else {
      // Keep category-specific products in natural order
      filteredProducts = products.where((p) {
        final parts = p.thumbnail.split("/");
        return parts.length > 3 && parts[2] == selectedCategory;
      }).toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
            // Curved top bar with gradient glow
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // curve top and bottom
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 22),
                    onPressed: () {
                      if (widget.onBackToHome != null) {
                        widget.onBackToHome!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),

                  // Center logo with shift ability
                  Transform.translate(
                    offset: const Offset(-5, 0),
                    child: Image.asset(
                      "assets/logo/logo1.png",
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.search, size: 22),
                    onPressed: () {
                      setState(() {
                        showSearch = !showSearch;
                      });
                      showSearch
                          ? _animController.forward()
                          : _animController.reverse();
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 12), // lowered content spacing
            if (widget.isHamperMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEF3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "🎁 Build Your Own Gift Hamper\nSelect products from any category to create your personalised gift box.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // 🔥 Animated Search Bar
            SizeTransition(
              sizeFactor: _fadeAnimation,
              axisAlignment: -1,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.95),
                              Colors.pink.shade50.withOpacity(0.90),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.18),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              blurRadius: 12,
                              spreadRadius: -4,
                              offset: Offset(0, -2),
                            ),
                            BoxShadow(
                              color: Colors.pink.shade200.withOpacity(0.12),
                              blurRadius: 26,
                              offset: Offset(0, 14),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search,
                                color: Colors.pinkAccent),
                            hintText: "Search the collection",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),


            SizedBox(
              height: 125,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
                        selectedCategory = categories[index];
                      });

                      // 🔥 AI tracking: category interest
                      if (categories[index] != "All") {
                        RecommendationEngine.trackCategoryClick(categories[index]);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          MouseRegion(
                            onEnter: (_) => setState(() => selectedCategoryIndex = index),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 250),
                              height: 85.5,
                              width: 85.5,
                              transform: Matrix4.identity()
                                ..scale(selectedCategoryIndex == index ? 1.08 : 1.0)
                                ..rotateZ(selectedCategoryIndex == index ? 0.04 : 0.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedCategoryIndex == index
                                      ? Colors.pinkAccent
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                gradient: LinearGradient(
                                  colors: [Colors.pink.shade200, Colors.purple.shade200],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedCategoryIndex == index
                                        ? Colors.pinkAccent.withOpacity(0.6)
                                        : Colors.pink.withOpacity(0.25),
                                    blurRadius: selectedCategoryIndex == index ? 18 : 6,
                                    spreadRadius: selectedCategoryIndex == index ? 2 : 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  _categoryIcon(categories[index]),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            categories[index].replaceAll("_", " ").toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (selectedCategoryIndex == index)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 4,
                              width: 4,
                              decoration: const BoxDecoration(
                                color: Colors.pinkAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔹 Home Hero Banner (category-aware)
            Builder(
              builder: (context) {
                final List<Product> bannerProducts;
                if (selectedCategory == "All") {
                  bannerProducts = List<Product>.from(products);
                } else {
                  bannerProducts = products.where((p) {
                    final parts = p.thumbnail.split("/");
                    return parts.length > 3 && parts[2] == selectedCategory;
                  }).toList();
                }
                bannerProducts.shuffle();
                // Safety fallback
                if (bannerProducts.isEmpty) {
                  return const SizedBox.shrink();
                }

                final month = DateTime.now().month;
                final bool festive = (month == 10 || month == 11);
                final bool valentine = (month == 2);

                final heroGradient = festive
                    ? const LinearGradient(colors: [Color(0xFFFFE082), Color(0xFFFFF7E0)])
                    : valentine
                        ? const LinearGradient(colors: [Color(0xFFFFC1D9), Color(0xFFFFF1F6)])
                        : const LinearGradient(colors: [Color(0xFFFFE3EC), Color(0xFFFFFFFF)]);

                String heroTag;

                final Map<String, List<String>> aestheticLines = {
                  "bottles": [
                    "Sip in Style ✨",
                    "Everyday Hydration, Beautifully",
                    "Designed for Your Daily Pour",
                    "Where Function Meets Aesthetic",
                    "Carry Calm in Every Sip",
                    "Minimal, Practical, Timeless",
                  ],
                  "candle": [
                    "Moments That Glow 🕯️",
                    "Soft Light, Calm Evenings",
                    "Where Warmth Begins",
                    "A Gentle Pause in Your Day",
                    "Set the Mood, Effortlessly",
                    "Light That Feels Like Home",
                  ],
                  "caps": [
                    "Top It Off ✨",
                    "Casual Days, Styled Right",
                    "Effortless Everyday Wear",
                    "Comfort Meets Street Style",
                    "Made for Easygoing Days",
                    "Simple Fits, Strong Vibe",
                  ],
                  "ceramic": [
                    "Crafted Calm 🤍",
                    "Slow Living Essentials",
                    "Art for Everyday Spaces",
                    "Thoughtfully Made Forms",
                    "Textures That Feel Grounded",
                    "Beauty in Every Curve",
                  ],
                  "hair_accessories": [
                    "Little Details, Big Charm ✨",
                    "Styled in Seconds",
                    "Everyday Hair Magic",
                    "Soft Touches That Shine",
                    "Made to Move With You",
                    "Gentle on Hair, Big on Style",
                  ],
                  "key_chain": [
                    "Small Things, Big Joy ✨",
                    "Carry a Little Cute",
                    "Tiny Details Matter",
                    "A Little Joy, Everywhere You Go",
                    "Everyday Companions",
                    "Minimal Add-ons, Maximum Charm",
                  ],
                  "letter": [
                    "Say It Your Way 💌",
                    "Words Made Special",
                    "Personal, Just Like You",
                    "Because Every Word Matters",
                    "Thoughts Turned Tangible",
                    "Moments Worth Remembering",
                  ],
                  "nails": [
                    "Polish Your Mood 💅",
                    "Tiny Art, Big Style",
                    "Everyday Nail Crush",
                    "Little Pops of Confidence",
                    "Details That Complete the Look",
                    "Style at Your Fingertips",
                  ],
                  "plusie": [
                    "Soft Hugs Only 🧸",
                    "Comfort You Can Feel",
                    "A Little Love to Hold",
                    "Gentle Comfort for Quiet Moments",
                    "Warmth in Its Softest Form",
                    "Always There When You Need It",
                  ],
                  "boy_friend": [
                    "For Him 💙",
                    "Gifts He’ll Love",
                    "Thoughtful Picks for Him",
                    "Because He Matters",
                    "Made for Your Person",
                    "Little Surprises, Big Smiles",
                  ],
                  "girl_friend": [
                    "For Her 💗",
                    "Gifts She’ll Adore",
                    "Thoughtfully Chosen",
                    "Because She’s Special",
                    "Love, Wrapped Perfectly",
                    "Moments Made Magical",
                  ],
                };

                String pickLine(String category) {
                  final list = aestheticLines[category];
                  if (list == null || list.isEmpty) {
                    return "Beautiful Finds, Just for You ✨";
                  }
                  list.shuffle();
                  return list.first;
                }

                if (festive) {
                  heroTag = "A Little Festive Magic ✨";
                } else if (valentine) {
                  heroTag = "Thoughtfully Chosen, With Love ❤️";
                } else if (selectedCategory != "All") {
                  heroTag = pickLine(selectedCategory);
                } else {
                  heroTag = "Beautiful Finds, Just for You ✨";
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: GestureDetector(
                    onTap: () {
                      // 🔥 AI tracking: hero product viewed
                      RecommendationEngine.trackProductView(bannerProducts.first);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsPage(product: bannerProducts.first),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 320,
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
                                bannerProducts.first.thumbnail,
                                fit: BoxFit.cover,
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
                );
              },
            ),

            const SizedBox(height: 12),



            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return GestureDetector(
                  onTap: () {
                    if (widget.isHamperMode) {
                      HamperBuilderController.toggle(product);
                    } else {
                      // 🔥 AI tracking: product viewed
                      RecommendationEngine.trackProductView(product);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(product: product),
                        ),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    transform: Matrix4.identity()
                      ..translate(0.0, -2.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              product.thumbnail,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Wishlist
                          Positioned(
                            top: 10,
                            left: 10,
                            child: ValueListenableBuilder<List<Product>>(
                              valueListenable: FavoritesController.items,
                              builder: (context, _, __) {
                                final isFav = FavoritesController.contains(product);

                                return IconButton(
                                  icon: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.pink,
                                  ),
                                  onPressed: () {
                                    FavoritesController.toggle(product);
                                  },
                                );
                              },
                            ),
                          ),

                          // Badge
                          if (_badgeFor(product) != null)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _badgeFor(product)!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ),

                          // Price at top-right, below badge if present
                          Positioned(
                            top: _badgeFor(product) != null ? 44 : 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                "₹${product.price}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),

                          // Name
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          if (widget.isHamperMode)
                            ValueListenableBuilder<List<Product>>(
                              valueListenable: HamperBuilderController.selectedItems,
                              builder: (_, selected, __) {
                                if (!selected.contains(product)) {
                                  return const SizedBox.shrink();
                                }
                                return Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Colors.pinkAccent,
                                      size: 22,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // "You may also like" recommendations section
            if (recommended.isNotEmpty) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "You may also like",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recommended.length > 6 ? 6 : recommended.length,
                  itemBuilder: (context, index) {
                    final product = recommended[index];

                    return GestureDetector(
                      onTap: () {
                        RecommendationEngine.trackProductView(product);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsPage(product: product),
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
                              offset: const Offset(0, 8),
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
            ],

              ],
            ),
          ),
        ), // <-- closes Container
      ),   // <-- closes SafeArea
      if (widget.isHamperMode)
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: ValueListenableBuilder<List<Product>>(
            valueListenable: HamperBuilderController.selectedItems,
            builder: (context, selected, _) {
              if (selected.isEmpty) {
                return const SizedBox.shrink();
              }

              return SafeArea(
                top: false,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 10,
                  ),
                  onPressed: () {
                    // ✅ ENFORCE MINIMUM ITEMS RULE
                    if (selected.length < 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please add at least 4 items to create a gift hamper 🎁",
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.pinkAccent,
                        ),
                      );
                      return;
                    }

                    final hamperId = CartController.editingHamperId ??
                        DateTime.now().millisecondsSinceEpoch.toString();

                    final hamper = GiftHamper(
                      id: hamperId,
                      items: List<Product>.from(selected),
                    );

                    CartController.addOrUpdateHamper(hamper);
                    HamperBuilderController.clear();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CartPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Add Gift Hamper to Cart (${selected.length} items)",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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

class _WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const waveHeight = 6.0;
    const waveWidth = 20.0;

    path.moveTo(0, waveHeight);
    for (double x = 0; x <= size.width; x += waveWidth) {
      path.quadraticBezierTo(
        x + waveWidth / 2,
        x % (waveWidth * 2) == 0 ? 0 : waveHeight * 2,
        x + waveWidth,
        waveHeight,
      );
    }

    path.lineTo(size.width, size.height - waveHeight);

    for (double x = size.width; x >= 0; x -= waveWidth) {
      path.quadraticBezierTo(
        x - waveWidth / 2,
        x % (waveWidth * 2) == 0 ? size.height : size.height - waveHeight * 2,
        x - waveWidth,
        size.height - waveHeight,
      );
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _OffersMarquee extends StatefulWidget {
  const _OffersMarquee();

  @override
  State<_OffersMarquee> createState() => _OffersMarqueeState();
}

class _OffersMarqueeState extends State<_OffersMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<String> offers = [
    "FLAT 20% OFF on Gift Hampers",
    "Buy 2 Get 1 on Candles",
    "Free Shipping above ₹999",
    "Limited Edition Bottles Available",
    "New Arrivals Just Dropped",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WavyClipper(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE4EC), Color(0xFFFFFFFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final dx = -_controller.value * width;

                return ClipRect(
                  child: SizedBox(
                    width: width,
                    child: Transform.translate(
                      offset: Offset(dx, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _offerRow(),
                          _offerRow(), // repeat for seamless loop
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _offerRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: offers
          .map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                t,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB2004D),
                  letterSpacing: 0.4,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}