// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

import '../controllers/favorites_controller.dart';
import '../data/products.dart';
import 'product_details_page.dart';
import '../models/product.dart';

class AllCategoriesPage extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final String? initialCategory;

  const AllCategoriesPage({
    super.key,
    this.onBackToHome,
    this.initialCategory,
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
      default:
        return "assets/icons/all.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> filteredProducts;

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
      body: SafeArea(
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
                      "assets/logo/logo.png",
                      height: 85,
                      width: 85,
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

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Shop by Category",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 125,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 10, // 10 aesthetic circular categories
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
                        selectedCategory = categories[index];
                      });
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
                if (festive) {
                  heroTag = "Festive Favourites · Limited";
                } else if (valentine) {
                  heroTag = "Made With Love ❤️";
                } else if (selectedCategory != "All") {
                  heroTag = "${selectedCategory.replaceAll('_', ' ').toUpperCase()} PICKS";
                } else {
                  heroTag = "Handpicked Just For You ✨";
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: GestureDetector(
                    onTap: () {
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(product: product),
                      ),
                    );
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

              ],
            ),
          ),
        ), // <-- closes Container
      ),   // <-- closes SafeArea
    );
  }
}