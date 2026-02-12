import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/cart_controllers.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? orderId;
  const PaymentSuccessPage({super.key, this.orderId});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _processing = true;

  @override
  void initState() {
    super.initState();

    // Fake payment processing delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // 🔥 Clear cart after successful order
        CartController.items.value = [];

        setState(() {
          _processing = false;
        });

        // ⏱ Auto return to home after showing success
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _processing ? _buildProcessing() : _buildSuccess(context),
      ),
    );
  }

  Widget _buildProcessing() {
    return Center(
      key: const ValueKey("processing"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            height: 70,
            width: 70,
            child: CircularProgressIndicator(strokeWidth: 5),
          ),
          SizedBox(height: 24),
          Text(
            "Processing Payment...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Center(
      key: const ValueKey("success"),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: Colors.green, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              "Payment Successful 💗",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your order has been placed successfully.",
              style: TextStyle(color: Colors.black54),
            ),
            if (widget.orderId != null) ...[
              const SizedBox(height: 8),
              Text(
                "Order ID: #${widget.orderId}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  "Continue Shopping",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}