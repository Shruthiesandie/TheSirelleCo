// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

import '../data/products.dart';
import 'product_details_page.dart';

class AllCategoriesPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AllCategoriesPage({super.key, this.onBackToHome});

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

  // Wishlist UI-only state
  final Set<String> _wishlist = {};

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
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Helper to get a category thumbnail image from first product in that category
  String? _categoryThumbnail(String category) {
    if (category == "All") {
      return products.isNotEmpty ? products.first.thumbnail : null;
    }

    try {
      final match = products.firstWhere(
        (p) {
          final parts = p.thumbnail.split("/");
          return parts.length > 3 && parts[2] == category;
        },
      );
      return match.thumbnail;
    } catch (_) {
      return null;
    }
  }

  // Helper to get multiple thumbnails for "All" category (creative collage)
  List<String> _allCategoryThumbnails({int limit = 4}) {
    return _allCategoryCachedThumbs.length > limit
        ? _allCategoryCachedThumbs.sublist(0, limit)
        : _allCategoryCachedThumbs;
  }

  // Build category content with frosted glass and product image thumbnail
  Widget _buildCategoryContent(String category, bool isActive) {
    // Special creative collage for "All"
    if (category == "All") {
      final thumbs = _allCategoryThumbnails();

      return ClipOval(
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          children: thumbs.map((t) {
            return Container(
              color: Colors.white.withOpacity(0.6),
              child: Image.asset(
                t,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        ),
      );
    }

    // Normal category: single product image
    final thumb = _categoryThumbnail(category);

    return ClipOval(
      child: Stack(
        children: [
          Positioned.fill(
            child: thumb != null
                ? Image.asset(
                    thumb,
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.pink.shade300,
                          Colors.purple.shade300,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
          ),

          if (isActive)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.45),
                      Colors.transparent,
                    ],
                    radius: 0.6,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = selectedCategory == "All"
        ? products
        : products.where((p) {
            final parts = p.thumbnail.split("/");
            return parts.length > 3 && parts[2] == selectedCategory;
          }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFCEEEE),
                Color(0xFFFFF6F6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
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
                                child: Stack(
                                  children: [
                                    // shimmer background
                                    AnimatedOpacity(
                                      duration: Duration(milliseconds: 600),
                                      opacity: 0.25,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.white, Colors.grey.shade200, Colors.white],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: AnimatedOpacity(
                                        duration: Duration(milliseconds: 300),
                                        opacity: selectedCategoryIndex == index ? 0.3 : 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.6),
                                                Colors.transparent,
                                              ],
                                              radius: 0.6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: _buildCategoryContent(
                                        categories[index],
                                        selectedCategoryIndex == index,
                                      ),
                                    ),
                                  ],
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

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                physics: const BouncingScrollPhysics(),
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

                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.55),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Wishlist
                            Positioned(
                              top: 10,
                              left: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _wishlist.contains(product.id)
                                        ? _wishlist.remove(product.id)
                                        : _wishlist.add(product.id);
                                  });
                                },
                                child: Icon(
                                  _wishlist.contains(product.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _wishlist.contains(product.id)
                                      ? Colors.pinkAccent
                                      : Colors.white,
                                ),
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
            ),

          ],
        ),
      ), // <-- closes Container
    ),   // <-- closes SafeArea
  );
}
}