import 'package:flutter/material.dart';

/// Curved home top bar with centered logo,
/// menu on left, search + membership on right.
class HomeTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;
  final VoidCallback onMembershipTap;
  final double logoShift;

  const HomeTopBar({
    super.key,
    required this.onMenuTap,
    required this.onSearchTap,
    required this.onMembershipTap,
    this.logoShift = 25,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Left Menu Button
          GestureDetector(
            onTap: onMenuTap,
            child: const Icon(Icons.menu, size: 26, color: Colors.grey),
          ),

          /// Perfectly Centered Logo
          Expanded(
            child: Center(
              child: Transform.translate(
                offset: Offset(logoShift, 0),
                child: Image.asset(
                  "assets/logo/logo.png",
                  height: 90,
                  width: 90,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          /// Right Icons
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: onSearchTap,
                  child: const Icon(Icons.search, size: 26, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: onMembershipTap,
                  child: const Icon(Icons.card_giftcard, size: 26, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}