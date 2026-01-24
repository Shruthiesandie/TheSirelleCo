import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../controllers/cart_controllers.dart';
import '../models/gift_hamper.dart';
import '../controllers/hamper_builder_controller.dart';
import '../pages/allcategories_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool useWallet = false;
  bool giftWrap = false;
  bool showSavings = false;
  String deliveryOption = "3–5 days";

  final TextEditingController noteController = TextEditingController();
  final TextEditingController giftMessageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFF6F9),
        centerTitle: false,
        title: const Text(
          "Cart",
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFF6F9),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 70),
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
            ValueListenableBuilder<List<dynamic>>(
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

            const SizedBox(height: 5),

            // SUMMARY (no ClipRect/BackdropFilter)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.pink.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  // WALLET TOGGLE
                  Row(
                    children: [
                      const Text("Use Sirelle Wallet (₹120)"),
                      const Spacer(),
                      Switch.adaptive(
                        value: useWallet,
                        onChanged: (v) => setState(() => useWallet = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<dynamic>>(
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
                      Switch.adaptive(
                        value: giftWrap,
                        onChanged: (v) => setState(() => giftWrap = v),
                      ),
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
                  // -------- PRICING, DELIVERY & NOTES --------
                  const Divider(),
                  const SizedBox(height: 14),
                  // SUBTOTAL
                  ValueListenableBuilder<List<dynamic>>(
                    valueListenable: CartController.items,
                    builder: (_, __, ___) => _summaryRow(
                      "Subtotal",
                      "₹${CartController.totalPrice}",
                    ),
                  ),
                  const SizedBox(height: 10),
                  // FREE DELIVERY PROGRESS
                  LayoutBuilder(
                    builder: (_, __) {
                      final remaining = (299 - CartController.totalPrice).clamp(0, 299);
                      final progress =
                          (CartController.totalPrice / 299).clamp(0.0, 1.0);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                ? "You've unlocked free delivery 🎉"
                                : "₹$remaining more for free shipping",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // SAVINGS
                  GestureDetector(
                    onTap: () => setState(() => showSavings = !showSavings),
                    child: Row(
                      children: [
                        _summaryRow("You Saved", "₹49"),
                        const Spacer(),
                        Icon(
                          showSavings ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  if (showSavings) ...[
                    const SizedBox(height: 6),
                    _summaryRow("Promo discount", "₹20"),
                    _summaryRow("Shipping saved", "₹29"),
                  ],
                  const SizedBox(height: 12),
                  // DELIVERY OPTIONS
                  const Text(
                    "Estimated delivery",
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      _deliveryChip("Tomorrow"),
                      _deliveryChip("2–3 days"),
                      _deliveryChip("3–5 days"),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // NOTE TO SELLER
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Add a note for the seller (optional)",
                      filled: true,
                      fillColor: Colors.pink.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  // GIFT MESSAGE
                  if (giftWrap) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: giftMessageController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Write a gift message 💝",
                        filled: true,
                        fillColor: Colors.pink.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _TrustItem(icon: Icons.lock, label: "Secure"),
                      _TrustItem(icon: Icons.undo, label: "Easy Returns"),
                      _TrustItem(icon: Icons.local_shipping, label: "Fast Delivery"),
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
  Widget _deliveryChip(String label) {
    final bool isSelected = deliveryOption == label;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          deliveryOption = label;
        });
      },
      selectedColor: Colors.pink.shade100,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.pinkAccent : Colors.black87,
      ),
    );
  }
}

/// CART ITEM CARD
class _CartItemCard extends StatelessWidget {
  final dynamic item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item is GiftHamper) {
      return _GiftHamperCard(hamper: item as GiftHamper);
    }
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


class _GiftHamperCard extends StatelessWidget {
  final GiftHamper hamper;
  const _GiftHamperCard({required this.hamper});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🎁 Custom Gift Hamper",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...hamper.items.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                "• ${p.name} – ₹${p.price}",
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Subtotal: ₹${hamper.subtotal.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    "Hamper Discount (-${hamper.discountPercent.toStringAsFixed(0)}%)",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "You Save: ₹${hamper.discountAmount.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total: ₹${hamper.totalPrice.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // MARK THIS HAMPER AS BEING EDITED
                      CartController.editingHamperId = hamper.id;

                      // PRELOAD ITEMS INTO BUILDER
                      HamperBuilderController.selectedItems.value =
                          List.from(hamper.items);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllCategoriesPage(
                            isHamperMode: true,
                          ),
                        ),
                      );
                    },
                    child: const Text("Edit"),
                  ),
                  TextButton(
                    onPressed: () {
                      CartController.removeHamper(hamper);
                    },
                    child: const Text(
                      "Remove",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.pinkAccent),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
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


