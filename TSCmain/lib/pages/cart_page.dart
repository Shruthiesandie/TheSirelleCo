import 'dart:ui';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../controllers/cart_controllers.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F9),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
                  child: Text(
                    "Your Bag",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    "Review your picks before checkout",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),

            Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 20), color: Colors.black12),

            // CART ITEMS
            ValueListenableBuilder<List<CartItem>>(
              valueListenable: CartController.items,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        "Your bag is empty",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _CartItemCard(item: items[index]);
                  },
                  separatorBuilder: (context, index) => const Divider(height: 24),
                );
              },
            ),

            // PROMO CODE SECTION
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer_outlined, color: Colors.pinkAccent),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Apply promo code",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => _PromoBottomSheet(),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.pinkAccent,
                    ),
                    child: const Text("Apply"),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 0, 8),
              child: const Text(
                "Explore Categories",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  return _CategoryCard(category: _categories[i]);
                },
              ),
            ),

            // SUMMARY (no ClipRect/BackdropFilter)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBFD),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBFD), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(34),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ValueListenableBuilder<List<CartItem>>(
                    valueListenable: CartController.items,
                    builder: (_, __, ___) => _summaryRow(
                      "Subtotal",
                      "₹${CartController.totalPrice}",
                    ),
                  ),
                  LayoutBuilder(
                    builder: (_, __) {
                      final remaining = (299 - CartController.totalPrice).clamp(0, 299);
                      final progress =
                          (CartController.totalPrice / 299).clamp(0.0, 1.0);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.pink.shade50,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            remaining == 0
                                ? "You’ve unlocked free delivery 🎉"
                                : "₹$remaining more for free shipping",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<List<CartItem>>(
                    valueListenable: CartController.items,
                    builder: (_, __, ___) => _summaryRow(
                      "You Saved",
                      "₹0",
                    ),
                  ),
                  const SizedBox(height: 8),
                  _summaryRow("Delivery", "Free"),
                  const SizedBox(height: 4),
                  const Text(
                    "Estimated delivery: 3–5 business days",
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<CartItem>>(
                    valueListenable: CartController.items,
                    builder: (_, __, ___) => _summaryRow(
                      "Total",
                      "₹${CartController.totalPrice}",
                      isTotal: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text("Gift wrap this order (₹49)"),
                      const Spacer(),
                      Switch.adaptive(value: false, onChanged: (_) {}),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("Add order protection (₹49)"),
                      const Spacer(),
                      Switch.adaptive(value: false, onChanged: (_) {}),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 16),
                    child: Text(
                      "Covers loss, theft & damage",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.apple),
                      SizedBox(width: 12),
                      Icon(Icons.payment),
                      SizedBox(width: 12),
                      Icon(Icons.account_balance_wallet_outlined),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                        overlayColor: Colors.pinkAccent.withOpacity(0.1),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Checkout Securely",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// CART ITEM CARD
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFF1F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                item.product.thumbnail,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "₹${item.product.price}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total: ₹${item.product.price * item.quantity}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (item.quantity <= 0)
                    const Text(
                      "Out of stock",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),

                  // Quantity Controls (Amazon style)
                  Row(
                    children: [
                      _qtyButton(
                        Icons.remove,
                        () => CartController.decrease(item.product),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Text(
                            item.quantity.toString(),
                            key: ValueKey(item.quantity),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      _qtyButton(
                        Icons.add,
                        () => CartController.add(item.product),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.pinkAccent,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    CartController.remove(item.product);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.redAccent,
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

/// SUMMARY ROW
Widget _summaryRow(String label, String value, {bool isTotal = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: isTotal ? 15 : 13,
          fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: Text(
          value,
          key: ValueKey(value),
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

Widget _qtyButton(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.pink.shade100,
      ),
      child: Icon(icon, size: 16),
    ),
  );
}

class _PromoBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Available Offers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _promoTile(context, "WELCOME10", "Save 10% on your first order"),
          _promoTile(context, "FREESHIP", "Free delivery on this order"),
          _promoTile(context, "SIRELLE50", "Flat ₹50 off"),
        ],
      ),
    );
  }

  Widget _promoTile(BuildContext context, String code, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Apply"),
          )
        ],
      ),
    );
  }
}


Future<List<String>> _loadAllAssetImages() async {
  final manifestJson = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifest = json.decode(manifestJson);

  return manifest.keys
      .where((path) =>
          path.startsWith('assets/') &&
          (path.endsWith('.png') ||
              path.endsWith('.jpg') ||
              path.endsWith('.jpeg')))
      .toList();
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: FutureBuilder<List<String>>(
                future: _loadAllAssetImages(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final images = snapshot.data!;
                    final randomImage =
                        images[Random(category.title.hashCode).nextInt(images.length)];
                    return Image.asset(
                      randomImage,
                      fit: BoxFit.cover,
                    );
                  }

                  return Container(
                    color: const Color(0xFFFFE4EC),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.pinkAccent,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              category.title,
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
    );
  }
}



final List<_CategoryItem> _categories = [
  _CategoryItem("Hair Care", "assets/images/category/hair.png"),
  _CategoryItem("Skin Care", "assets/images/category/skin.png"),
  _CategoryItem("Accessories", "assets/images/category/accessories.png"),
  _CategoryItem("Wellness", "assets/images/category/wellness.png"),
  _CategoryItem("Gift Sets", "assets/images/category/gifts.png"),
];

class _CategoryItem {
  final String title;
  final String image;
  _CategoryItem(this.title, this.image);
}
