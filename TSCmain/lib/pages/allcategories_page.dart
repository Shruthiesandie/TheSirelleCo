import 'package:flutter/material.dart';
import 'dart:ui';

class AllCategoriesPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AllCategoriesPage({super.key, this.onBackToHome});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage>
    with SingleTickerProviderStateMixin {
  bool showSearch = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();

  int selectedCategoryIndex = -1;

  final List<String> categories = [
    "All",
    "Dresses",
    "Jewellery",
    "Tops",
    "Hoodies",
    "Shoes",
    "Bags",
    "Accessories"
  ];

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: SafeArea(
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
                            hintText: "Search products...",
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
                itemCount: 10, // 10 aesthetic circular categories
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
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
                                ..rotateZ(selectedCategoryIndex == index ? 0.05 : 0.0),
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
                                    color: Colors.pink.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Stack(
                                  children: [
                                    // shimmer background
                                    AnimatedOpacity(
                                      duration: Duration(milliseconds: 600),
                                      opacity: 0.6,
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
                                    // placeholder icon
                                    Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 34,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Item ${index + 1}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Body
            const Expanded(
              child: Center(
                child: Text(
                  "Categories Page",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
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