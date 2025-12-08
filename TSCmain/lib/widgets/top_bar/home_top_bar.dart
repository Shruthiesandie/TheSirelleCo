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
        height: 120, // slightly taller to show wave
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onMenuTap,
              child: const Icon(Icons.menu, size: 26, color: Colors.grey),
            ),

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

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: onSearchTap,
                    child:
                        const Icon(Icons.search, size: 26, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: onMembershipTap,
                    child: const Icon(Icons.card_giftcard,
                        size: 26, color: Colors.grey),
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

/// custom wave bottom clipping
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.55);

    // wave curve
    path.cubicTo(
      size.width * 0.20, size.height * 0.85,  // lower first control
      size.width * 0.50, size.height * 0.30,  // higher peak dip
      size.width * 0.80, size.height * 0.85,  // lower second control
    );

    path.lineTo(size.width, size.height * 0.55 + 10);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}