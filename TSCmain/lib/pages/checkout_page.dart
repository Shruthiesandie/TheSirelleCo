import 'package:flutter/material.dart';
import '../controllers/cart_controllers.dart';
import 'payment_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final ValueNotifier<String?> _appliedCoupon = ValueNotifier(null);
  final ValueNotifier<double> _savedAmount = ValueNotifier(0);
  final ValueNotifier<double> _grandTotal = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // DELIVERY ADDRESS
          const Text(
            "DELIVERY ADDRESS",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: ValueListenableBuilder<String?>(
              valueListenable: CartController.selectedAddress,
              builder: (context, String? address, _) {
                final now = DateTime.now();
                final eta = now.add(const Duration(days: 1));
                final etaText = "Delivery by ${eta.day}/${eta.month}, 7 PM";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Selected Address", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(address ?? "No address selected"),
                    const SizedBox(height: 4),
                    Text(etaText),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ORDER SUMMARY HEADER
          const Text(
            "ORDER SUMMARY",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 8),

          // DUMMY PRODUCT CARD
          ValueListenableBuilder<List<dynamic>>(
            valueListenable: CartController.items,
            builder: (context, items, _) {
              if (items.isEmpty) {
                return const Text("Your cart is empty");
              }

              return Column(
                children: items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            item.product.imageUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${(item.product.price * (item.quantity ?? 1)).toStringAsFixed(0)}  •  Qty ${(item.quantity ?? 1)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // COUPON SECTION
          const Text(
            "COUPONS",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: ValueListenableBuilder<String?>(
              valueListenable: _appliedCoupon,
              builder: (context, coupon, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(coupon == null ? "No coupon applied" : "Coupon: $coupon"),
                    GestureDetector(
                      onTap: () {
                        if (coupon == null) {
                          _appliedCoupon.value = "SIRELLE10";
                        } else {
                          _appliedCoupon.value = null;
                        }
                        setState(() {});
                      },
                      child: Text(
                        coupon == null ? "Apply" : "Remove",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // PRICE DETAILS
          const Text(
            "PRICE DETAILS",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<List<dynamic>>(
            valueListenable: CartController.items,
            builder: (context, items, _) {
              double itemTotal = 0;
              for (var i in items) {
                final qty = (i.quantity ?? 1);
                itemTotal += (i.product.price * qty);
              }

              const double deliveryFee = 40;
              const double packaging = 10;
              final double gst = itemTotal * 0.18;

              double discount = 0;
              if (_appliedCoupon.value != null) {
                discount = itemTotal * 0.10;
              }

              final double grandTotal =
                  itemTotal - discount + deliveryFee + packaging + gst;
              // Update notifiers AFTER build to avoid setState during build error
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _savedAmount.value = discount;
                  _grandTotal.value = grandTotal;
                }
              });

              return Column(
                children: [
                  _priceRow("Item Total", "₹${itemTotal.toStringAsFixed(0)}"),
                  _priceRow("Delivery Fee", "₹${deliveryFee.toStringAsFixed(0)}"),
                  _priceRow("Packaging", "₹${packaging.toStringAsFixed(0)}"),
                  _priceRow("GST (18%)", "₹${gst.toStringAsFixed(0)}"),
                  ValueListenableBuilder<double>(
                    valueListenable: _savedAmount,
                    builder: (context, saved, _) {
                      if (saved <= 0) return const SizedBox.shrink();
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          "You saved ₹${saved.toStringAsFixed(0)}",
                          key: ValueKey(saved),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  _priceRow("Discount", "-₹${discount.toStringAsFixed(0)}"),
                  const Divider(height: 26),
                  _priceRow("Grand Total", "₹${grandTotal.toStringAsFixed(0)}", bold: true),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // CHECKOUT BUTTON
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final total = _grandTotal.value;

                if (CartController.items.value.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cart is empty")),
                  );
                  return;
                }

                if (CartController.selectedAddress.value == null ||
                    CartController.selectedAddress.value!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select an address")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(total: total),
                  ),
                );
              },
              child: ValueListenableBuilder<double>(
                valueListenable: _grandTotal,
                builder: (context, total, _) {
                  return Text(
                    total <= 0
                        ? "Proceed to Payment"
                        : "Proceed to Pay ₹${total.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

Widget _priceRow(String title, String value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}