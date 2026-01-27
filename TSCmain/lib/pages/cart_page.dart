import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../controllers/cart_controllers.dart';
import '../models/gift_hamper.dart';
import '../controllers/hamper_builder_controller.dart';
import '../pages/allcategories_page.dart';
import '../pages/love_page.dart';
import '../controllers/favorites_controller.dart';


class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool useWallet = false;
  bool giftWrap = false;
  bool orderProtection = false;
  bool showSavings = false;
  bool showSellerNote = false;
  bool showGiftMessage = false;
  String deliveryOption = "3–5 days";

  static const int walletBalance = 120;
  static const int giftWrapFee = 49;
  static const int orderProtectionFee = 49;

  static const int sameDayDeliveryFee = 99;
  static const int expressDeliveryFee = 49;
  static const int standardDeliveryFee = 0;

  int get deliveryFee {
    switch (deliveryOption) {
      case "Tomorrow":
        return sameDayDeliveryFee;
      case "2–3 days":
        return expressDeliveryFee;
      case "3–5 days":
      default:
        return standardDeliveryFee;
    }
  }

  final TextEditingController noteController = TextEditingController();
  final TextEditingController giftMessageController = TextEditingController();

  int get cartSubtotal => CartController.totalPrice;

  int get extrasTotal {
    int total = 0;
    if (giftWrap) total += giftWrapFee;
    if (orderProtection) total += orderProtectionFee;
    total += deliveryFee;
    return total;
  }

  int get walletDeduction {
    if (!useWallet) return 0;
    return walletBalance.clamp(0, cartSubtotal + extrasTotal);
  }

  int get finalTotal {
    final total = cartSubtotal + extrasTotal - walletDeduction;
    return total < 0 ? 0 : total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.pinkAccent.withOpacity(0.15),
        backgroundColor: const Color(0xFFFCEEEE),
        centerTitle: true,
        title: ValueListenableBuilder<List<dynamic>>(
          valueListenable: CartController.items,
          builder: (context, items, _) {
            final cartItems = items.whereType<CartItem>().toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cartItems.length} item${cartItems.length == 1 ? '' : 's'}',
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
            valueListenable: FavoritesController.items,
            builder: (context, items, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LovePage(),
                        ),
                      );
                    },
                  ),
                  if (items.isNotEmpty)
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
                          items.length > 9 ? '9+' : '${items.length}',
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
      backgroundColor: const Color(0xFFFFF6F9),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<List<dynamic>>(
          valueListenable: CartController.items,
          builder: (context, items, _) {
            return ListView(
              padding: const EdgeInsets.only(bottom: 70),
              physics: items.isEmpty
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
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
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
              ],
            ),

            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.black12,
            ),

            // CART ITEMS
            ValueListenableBuilder<List<dynamic>>(
              valueListenable: CartController.items,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.pinkAccent.withOpacity(0.18),
                                Colors.pinkAccent.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 76,
                            color: Colors.pinkAccent,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          "Your cart is empty",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Add items you love to get started ✨",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: 180,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AllCategoriesPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Explore products",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 28),
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFF1F6),
                                Color(0xFFFFFAFC),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withOpacity(0.08),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 18,
                                    color: Colors.pinkAccent,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Wallet & Offers",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _emptyBenefit("Use wallet balance"),
                              _emptyBenefit("Apply exclusive promo codes"),
                              _emptyBenefit("Unlock free delivery offers"),
                            ],
                          ),
                        ),
                      ],
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
                  separatorBuilder: (context, index) =>
                      const Divider(height: 24),
                );
              },
            ),

            // SUMMARY (only when cart has items)
            ValueListenableBuilder<List<dynamic>>(
              valueListenable: CartController.items,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Use Sirelle Wallet",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            useWallet
                                ? "₹$walletDeduction applied • Balance ₹${walletBalance - walletDeduction}"
                                : "Balance ₹$walletBalance",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: useWallet,
                        onChanged: (v) => setState(() => useWallet = v),
                      ),
                    ],
                  ),
                  // PROMO CODE (INLINE)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF1F6), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.pink.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_offer_outlined,
                            color: Colors.pinkAccent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Apply promo code",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Save more on this order",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.pinkAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (_) => _PromoBottomSheet(),
                            );
                          },
                          child: const Text(
                            "APPLY",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<List<dynamic>>(
                    valueListenable: CartController.items,
                    builder: (_, __, ___) =>
                        _summaryRow("Total", "₹$finalTotal", isTotal: true),
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
                      Switch.adaptive(
                        value: orderProtection,
                        onChanged: (v) => setState(() => orderProtection = v),
                      ),
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
                    builder: (_, __, ___) =>
                        _summaryRow("Subtotal", "₹$cartSubtotal"),
                  ),
                  if (giftWrap) _summaryRow("Gift wrap", "₹$giftWrapFee"),
                  if (orderProtection)
                    _summaryRow("Order protection", "₹$orderProtectionFee"),
                  if (deliveryFee > 0)
                    _summaryRow(
                      "Delivery (${deliveryOption})",
                      "₹$deliveryFee",
                    ),
                  if (useWallet)
                    _summaryRow("Wallet applied", "-₹$walletDeduction"),
                  const SizedBox(height: 10),
                  // FREE DELIVERY PROGRESS
                  LayoutBuilder(
                    builder: (_, __) {
                      final remaining = (299 - CartController.totalPrice).clamp(
                        0,
                        299,
                      );
                      final progress = (CartController.totalPrice / 299).clamp(
                        0.0,
                        1.0,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.pink.shade50,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.pinkAccent,
                            ),
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
                  // DELIVERY OPTIONS (REDESIGNED)
                  const Text(
                    "Estimated delivery",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _deliveryCard(
                        label: "Tomorrow",
                        subtitle: "Priority delivery",
                        price: "+₹99",
                        isSelected: deliveryOption == "Tomorrow",
                        onTap: () =>
                            setState(() => deliveryOption = "Tomorrow"),
                      ),
                      const SizedBox(width: 10),
                      _deliveryCard(
                        label: "2–3 days",
                        subtitle: "Express",
                        price: "+₹49",
                        isSelected: deliveryOption == "2–3 days",
                        onTap: () =>
                            setState(() => deliveryOption = "2–3 days"),
                      ),
                      const SizedBox(width: 10),
                      _deliveryCard(
                        label: "3–5 days",
                        subtitle: "Standard",
                        price: "FREE",
                        isSelected: deliveryOption == "3–5 days",
                        onTap: () =>
                            setState(() => deliveryOption = "3–5 days"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // NOTE TO SELLER (TAP TO EXPAND)
                  GestureDetector(
                    onTap: () =>
                        setState(() => showSellerNote = !showSellerNote),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Add a note for the seller",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                showSellerNote
                                    ? Icons.expand_less
                                    : Icons.edit_outlined,
                                size: 18,
                              ),
                            ],
                          ),
                          if (showSellerNote) ...[
                            const SizedBox(height: 8),
                            TextField(
                              controller: noteController,
                              maxLines: 3,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: "Write your note here…",
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // GIFT MESSAGE (TAP TO EXPAND)
                  if (giftWrap) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          setState(() => showGiftMessage = !showGiftMessage),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Write a gift message 💝",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  showGiftMessage
                                      ? Icons.expand_less
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: Colors.pinkAccent,
                                ),
                              ],
                            ),
                            if (showGiftMessage) ...[
                              const SizedBox(height: 8),
                              TextField(
                                controller: giftMessageController,
                                maxLines: 3,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText:
                                      "Your message will be printed on the card 💌",
                                  border: InputBorder.none,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.apple),
                      SizedBox(width: 16),
                      Icon(Icons.payment),
                      SizedBox(width: 16),
                      Icon(Icons.account_balance_wallet_outlined),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _TrustItem(icon: Icons.lock, label: "Secure"),
                      _TrustItem(icon: Icons.undo, label: "Easy Returns"),
                      _TrustItem(
                        icon: Icons.local_shipping,
                        label: "Fast Delivery",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
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
                );
              },
            ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
}

  // Redesigned delivery card widget
  Widget _deliveryCard({
    required String label,
    required String subtitle,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.pink.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? Colors.pinkAccent : Colors.black12,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.pinkAccent : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Text(
                price,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: price == "FREE" ? Colors.green : Colors.pinkAccent,
                ),
              ),
            ],
          ),
        ),
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
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14),
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
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
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
                ValueListenableBuilder<List<dynamic>>(
                  valueListenable: FavoritesController.items,
                  builder: (context, favorites, _) {
                    final isLoved = favorites.contains(item.product);

                    return IconButton(
                      onPressed: () {
                        FavoritesController.toggle(item.product);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isLoved
                                  ? 'Removed from wishlist'
                                  : 'Added to wishlist',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(
                        isLoved ? Icons.favorite : Icons.favorite_border,
                        color: Colors.pinkAccent,
                      ),
                    );
                  },
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
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14),
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
                    style: const TextStyle(fontSize: 12, color: Colors.green),
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
                      HamperBuilderController.selectedItems.value = List.from(
                        hamper.items,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllCategoriesPage(isHamperMode: true),
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
          const Text(
            "Available Offers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
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
                Text(
                  code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }
}


Widget _emptyBenefit(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 14,
          color: Colors.pinkAccent,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
      ],
    ),
  );
}

/// LOVE / WISHLIST CONTROLLER (temporary local fix)
class LoveController {
  static ValueNotifier<List<dynamic>> items = ValueNotifier([]);

  static void add(dynamic product) {
    if (!items.value.contains(product)) {
      items.value = [...items.value, product];
    }
  }

  static void remove(dynamic product) {
    items.value = [...items.value]..remove(product);
  }

  static bool contains(dynamic product) {
    return items.value.contains(product);
  }
}