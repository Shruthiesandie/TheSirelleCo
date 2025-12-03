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
    return ClipPath(
      clipper: TopBarClipper(),
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Left Menu Button
            IconButton(
              icon: const Icon(Icons.menu, size: 24),
              onPressed: onMenuTap,
            ),

            /// Perfectly Centered Logo
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: Offset(logoShift, 0),
                  child: Image.asset(
                    "assets/logo/logo.png",
                    height: 85,
                    width: 85,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            /// Right Icons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search, size: 22),
                  onPressed: onSearchTap,
                ),
                IconButton(
                  icon: const Icon(Icons.workspace_premium, size: 22),
                  onPressed: onMembershipTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Curve is maintained using custom clipper
class TopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double curve = 25;
    return Path()
      ..lineTo(0, size.height - curve)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + curve,
        size.width,
        size.height - curve,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}