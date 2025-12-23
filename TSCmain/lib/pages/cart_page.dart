import 'package:flutter/material.dart';
import '../controllers/cart_controllers.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Expanded(
              child: ValueListenableBuilder<List<CartItem>>(
                valueListenable: CartController.items,
                builder: (context, items, _) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        "Your bag is empty",
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _CartItemCard(item: items[index]);
                    },
                  );
                },
              ),
            ),

            // SUMMARY + CTA
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
                  const SizedBox(height: 8),
                  _summaryRow("Delivery", "Free"),
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
      Text(
        value,
        style: TextStyle(
          fontSize: isTotal ? 15 : 13,
          fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget _qtyButton(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
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
