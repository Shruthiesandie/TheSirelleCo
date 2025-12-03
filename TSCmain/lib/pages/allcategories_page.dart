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
            /// ⭐ Curved Top Bar (same as home)
            ClipPath(
              clipper: TopBarClipper(),
              child: Container(
                height: 90,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),

                    /// Center Logo
                    Image.asset(
                      "assets/logo/logo.png",
                      height: 75,
                      width: 75,
                      fit: BoxFit.contain,
                    ),

                    /// Dummy placeholder for spacing (keeps logo centered)
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),

            /// Page Body
            const Expanded(
              child: Center(
                child: Text(
                  "Categories Pageeee",
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

/// SAME clipper used in HomePage
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