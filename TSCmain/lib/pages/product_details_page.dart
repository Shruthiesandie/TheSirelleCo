import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../controllers/cart_controllers.dart';
import '../services/recommendation_engine.dart';
import '../services/product_gallery.dart';

import '../services/product_service.dart';
import '../services/behavior_logger.dart';


class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState()
  ;
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _wishlisted = false;
  bool _showHeartBurst = false;
  bool _addedFeedback = false;
  int _quantity = 0;

  late final ScrollController _scrollController;

  late AnimationController _heartController;
  late Animation<double> _heartScale;

  double _headerOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    // 🔥 AI Behavior Log — Product page opened
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      BehaviorLogger.log(
        userId: user.uid,
        screenName: "product_details_page",
        actionType: "navigation",
        actionValue: widget.product.uiId,
      );
    }
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      setState(() {
        _headerOpacity = (offset / 120).clamp(0.0, 1.0);
      });
    });

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _heartScale = Tween<double>(begin: 1.0, end: 1.3)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_heartController);
  }

  @override
  void dispose() {
    // Release image cache to free Metal/IOKit memory on iOS
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    _scrollController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final List<String> displayImages =
    ProductGallery.getImages(product.uiId, product.imageUrl);
    final bool hasMultipleImages = displayImages.length > 1;

    return HeroMode(
      enabled: false,
      child: Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // COLLAPSING HERO IMAGE
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.6,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _headerOpacity,
              child: Text(
                product.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final delta =
                          (constraints.maxHeight - kToolbarHeight).clamp(0.0, 300.0);

                      return PageView.builder(
                        itemCount: displayImages.length,
                        onPageChanged: hasMultipleImages
                            ? (i) => setState(() => _currentIndex = i)
                            : null,
                        allowImplicitScrolling: false,
                        padEnds: false,
                        itemBuilder: (context, index) {
                          return Transform.translate(
                            offset: Offset(0, -delta * 0.15),
                            child: GestureDetector(
                              onDoubleTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _wishlisted = !_wishlisted;
                                  _showHeartBurst = true;
                                });
                                _heartController.forward(from: 0);
                                Future.delayed(const Duration(milliseconds: 700), () {
                                  if (mounted) setState(() => _showHeartBurst = false);
                                });
                              },
                              child: Image(
                                image: ResizeImage(
                                  AssetImage(displayImages[index]),
                                  width: MediaQuery.of(context).size.width.toInt(),
                                ),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.low,
                                errorBuilder: (_, __, ___) =>
                                    const Center(
                                      child: Icon(Icons.broken_image, size: 40),
                                    ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // HEART BURST OVERLAY
                  if (_showHeartBurst)
                    Center(
                      child: ScaleTransition(
                        scale: _heartScale,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.pinkAccent.withOpacity(0.85),
                          size: 96,
                        ),
                      ),
                    ),

                  // TOP ACTIONS
                  Positioned(
                    top: 40,
                    left: 16,
                    child: _topActionButton(
                      onTap: () => Navigator.pop(context),
                      child: _circleIcon(Icons.arrow_back_ios_new),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: _topActionButton(
                      onTap: () {
                        setState(() => _wishlisted = !_wishlisted);
                        _heartController.forward(from: 0);
                      },
                      child: ScaleTransition(
                        scale: _heartScale,
                        child: _circleIcon(
                          _wishlisted
                              ? Icons.favorite
                              : Icons.favorite_border,
                          active: _wishlisted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // PAGE INDICATORS
          if (hasMultipleImages)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    displayImages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentIndex == i
                            ? Colors.black
                            : Colors.black26,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // DETAILS CONTENT
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 180),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // NAME & SUBTITLE & PRICE
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Handcrafted · Limited Edition",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "₹${product.price}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),

                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 14),

                  // DESCRIPTION
                  const Text(
                    "Designed with intention. Crafted to elevate your everyday style. "
                    "A perfect balance of form, function, and finish.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // DETAILS SECTION
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "THE DETAILS",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 10),
                        _DetailRow(text: "Handcrafted premium finish"),
                        _DetailRow(text: "Designed for everyday use"),
                        _DetailRow(text: "Carefully quality-checked"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // WHY YOU’LL LOVE IT
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "WHY YOU’LL LOVE IT",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 12),
                      _LoveChip(text: "Perfect for gifting"),
                      _LoveChip(text: "Minimal & aesthetic design"),
                      _LoveChip(text: "Thoughtful craftsmanship"),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // DELIVERY INFO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _InfoBadge(
                          icon: Icons.local_shipping_outlined,
                          text: "Free delivery"),
                      _InfoBadge(
                          icon: Icons.refresh_outlined,
                          text: "7-day returns"),
                      _InfoBadge(
                          icon: Icons.verified_outlined,
                          text: "Quality checked"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ✨ LETTER CUSTOMIZATION SECTION
                  if (product.category.toLowerCase() == "letter") ...[
                    const SizedBox(height: 28),
                    const Text(
                      "CUSTOMIZE YOUR LETTER",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Message input
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const TextField(
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Write what you want inside the letter...",
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Image selection mock UI
                    const Text(
                      "Add Photos (Optional)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 10),
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: const Icon(Icons.add_a_photo_outlined, size: 20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),
                  ],
                  // SIMILAR PRODUCTS
                  const Text(
                    "You may also like",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  FutureBuilder<List<Product>>(
                    future: ProductService.fetchProducts(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          height: 160,
                          alignment: Alignment.center,
                          child: const Text(
                            "More from this collection coming soon",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }

                      final List<Product> recommended = RecommendationEngine.recommend(
                        allProducts: snapshot.data!,
                        category: product.category,
                        budget: null,
                        vibe: null,
                      );

                      final suggestions = recommended
                          .where((p) => p.uiId != product.uiId)
                          .take(6)
                          .toList();

                      if (suggestions.isEmpty) {
                        return Container(
                          height: 160,
                          alignment: Alignment.center,
                          child: const Text(
                            "More from this collection coming soon",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: SizedBox(
                          height: 148,
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: suggestions.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final item = suggestions[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsPage(product: item),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 120,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.asset(
                                            item.imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        height: 44,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "₹${item.price}",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
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
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      // STICKY CTA (Nike / Zara style)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ValueListenableBuilder<List<dynamic>>(
            valueListenable: CartController.items,
            builder: (context, items, _) {
              final cartItem = items
                  .whereType<CartItem>()
                  .where((c) => c.product.uiId == product.uiId)
                  .toList();
              _quantity = cartItem.isEmpty ? 0 : cartItem.first.quantity;

              if (_quantity == 0) {
                return ElevatedButton(
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Login to add to cart"),
                        ),
                      );
                      return;
                    }

                    // 🔥 AI Behavior Log — add to cart
                    if (user != null) {
                      BehaviorLogger.log(
                        userId: user.uid,
                        screenName: "product_details_page",
                        actionType: "click",
                        actionValue: "add_to_cart_" + product.uiId,
                      );
                    }

                    CartController.add(product);
                    HapticFeedback.mediumImpact();
                    setState(() => _addedFeedback = true);
                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (mounted) setState(() => _addedFeedback = false);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _addedFeedback
                        ? const Row(
                            key: ValueKey("added"),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text("Added"),
                            ],
                          )
                        : const Text(
                            "Add to Bag",
                            key: ValueKey("add"),
                          ),
                  ),
                );
              }

              return Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        CartController.decrease(product);
                        HapticFeedback.lightImpact();
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "$_quantity in Cart",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;

                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Login to add to cart"),
                            ),
                          );
                          return;
                        }

                        // 🔥 AI Behavior Log — increase quantity
                        if (user != null) {
                          BehaviorLogger.log(
                            userId: user.uid,
                            screenName: "product_details_page",
                            actionType: "click",
                            actionValue: "increase_qty_" + product.uiId,
                          );
                        }

                        CartController.add(product);
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      ),
    );
  }


  Widget _circleIcon(
    IconData icon, {
    bool active = false,
  }) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 18,
        color: active ? Colors.pinkAccent : Colors.black,
      ),
    );
  }

  Widget _topActionButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        containedInkWell: false,
        highlightShape: BoxShape.circle,
        child: SizedBox(
          height: 48,
          width: 48,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String text;
  const _DetailRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              size: 16, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoveChip extends StatelessWidget {
  final String text;
  const _LoveChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            height: 6,
            width: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
