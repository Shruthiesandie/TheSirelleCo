import 'package:flutter/material.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: SafeArea(
        child: Column(
          children: [
            // Same curved-ish style as home (rounded bottom bar)
            ClipPath(
              clipper: TopBarClipper(),
              child: Container(
                height: 90,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: Colors.white,
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Center logo
                  Transform.translate(
                    offset: const Offset(-5, 0), // adjust value to shift left/right
                    child: Image.asset(
                      "assets/logo/logo.png",
                      height: 85,
                      width: 85,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Spacer to balance right side
                  const SizedBox(width: 40),
                ],
              ),
              ),
            ),

            // Body
            const Expanded(
              child: Center(
                child: Text(
                  "Categories Page",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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