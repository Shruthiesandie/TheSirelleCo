import 'package:flutter/material.dart';

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
    return ClipPath(
      clipper: TopBarClipper(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        height: 135,
        padding: const EdgeInsets.symmetric(horizontal: 12),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Left Menu Button
            GestureDetector(
              onTap: onMenuTap,
              child: const Icon(Icons.menu, size: 26, color: Colors.grey),
            ),

            /// Center Logo
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: Offset(logoShift, -10),   // lifted slightly above curve
                  child: Image.asset(
                    "assets/logo/logo.png",
                    height: 90,
                    width: 90,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            /// Right Actions
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
      ),
    );
  }
}

/// Smooth premium wave clip — balanced, logo-safe, aesthetic S-curve
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;

    // Lifted further up so it stays away from the logo, but still shows a nice dip
    final double yStart = h * 0.55; // edges pushed further down
    final double yDip   = h * 0.80; // maintain dip depth

    path.moveTo(0, 0);
    path.lineTo(0, yStart);

    // Left ➜ mid smooth carved arc (curves already from the start)
    path.cubicTo(
      w * 0.08, yStart + (yDip - yStart) * 0.75, // stronger edge carve
      w * 0.32, yDip,
      w * 0.50, yDip,
    );

    // Mid ➜ right smooth carved arc (mirrored behaviour, curved near the end)
    path.cubicTo(
      w * 0.68, yDip,
      w * 0.92, yStart + (yDip - yStart) * 0.75, // stronger edge carve
      w,       yStart,
    );

    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}