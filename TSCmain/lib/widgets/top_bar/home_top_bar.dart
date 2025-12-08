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

        // Increased slightly to give logo & curve breathing space
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
                  offset: Offset(logoShift, -10),
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

/// Custom wave clipping — lowered + smoother aesthetic curve
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;

    // Base line where the curve starts from left and right
    final double yBase = h * 0.65; // lower start line
    final double yDip = h * 0.88;  // gentle dip

    path.moveTo(0, 0);
    // Left edge down to the start of the curve
    path.lineTo(0, yBase);

    // First half of the smile curve
    path.cubicTo(
      w * 0.20, yBase + (yDip - yBase) * 0.25,
      w * 0.40, yDip,
      w * 0.50, yDip,
    );

    // Second half of the smile curve
    path.cubicTo(
      w * 0.60, yDip,
      w * 0.80, yBase + (yDip - yBase) * 0.25,
      w,       yBase,
    );

    // Right edge back up to the top
    path.lineTo(w, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}