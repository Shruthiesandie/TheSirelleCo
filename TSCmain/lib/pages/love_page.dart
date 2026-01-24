import 'package:flutter/material.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/cart_controllers.dart';
import '../models/product.dart';
import 'product_details_page.dart';
import 'cart_page.dart';
import 'allcategories_page.dart';

class LovePage extends StatefulWidget {
  const LovePage({super.key});
  @override
  State<LovePage> createState() => _LovePageState();
}

class _LovePageState extends State<LovePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.pinkAccent.withOpacity(0.15),
        backgroundColor: const Color(0xFFFCEEEE),
        centerTitle: true,
        title: ValueListenableBuilder<List<Product>>(
          valueListenable: FavoritesController.items,
          builder: (context, favorites, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Wishlist',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${favorites.length} item${favorites.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          ValueListenableBuilder<List<dynamic>>(
            valueListenable: CartController.items,
            builder: (context, items, _) {
              final cartItems = items.whereType<CartItem>().toList();
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (cartItems.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartItems.length > 9 ? '9+' : '${cartItems.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: FavoritesController.items,
        builder: (context, favorites, _) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 72,
                    color: Colors.pink.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No favourites yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap the heart to save items you love',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllCategoriesPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Explore products",
                      style: TextStyle(
                        letterSpacing: 0.4,
                        color: Colors.pinkAccent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final product = favorites[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: product),
                    ),
                  );
                },
                onLongPress: () {
                  FavoritesController.toggle(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Removed from favourites'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 220),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF1F6), Color(0xFFFFFFFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(22),
                                        ),
                                        child: Image.asset(
                                          product.thumbnail,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.12),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          FavoritesController.toggle(product);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Removed from favourites'),
                                              behavior: SnackBarBehavior.floating,
                                              duration: const Duration(seconds: 3),
                                              action: SnackBarAction(
                                                label: 'UNDO',
                                                onPressed: () {
                                                  FavoritesController.toggle(product);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.85),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.pinkAccent.withOpacity(0.25),
                                                blurRadius: 12,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: TweenAnimationBuilder<double>(
                                            tween: Tween(begin: 1.0, end: 1.2),
                                            duration: const Duration(milliseconds: 150),
                                            builder: (context, value, child) {
                                              return Transform.scale(scale: value, child: child);
                                            },
                                            child: const Icon(
                                              Icons.favorite,
                                              size: 16,
                                              color: Colors.pinkAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.3,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${product.price}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // 🛒 MOVE TO CART BUTTON
                                    SizedBox(
                                      width: double.infinity,
                                      height: 34,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.pinkAccent.withOpacity(0.4)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () {
                                          CartController.add(product);
                                          FavoritesController.toggle(product);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Moved to cart'),
                                              behavior: SnackBarBehavior.floating,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Move to Cart",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                            color: Colors.pinkAccent,
                                          ),
                                        ),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}