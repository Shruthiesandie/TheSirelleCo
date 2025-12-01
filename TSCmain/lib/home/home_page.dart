// lib/pages/ice_cream_landing_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _heroSection(width),
            _wave(height: 110),
            const SizedBox(height: 40),
            _featuredSection(width),
            const SizedBox(height: 70),
            _wave(height: 120, reverse: true),
            const SizedBox(height: 40),
            _aboutSection(width),
            const SizedBox(height: 60),
            _wave(height: 120),
            const SizedBox(height: 50),
            _gallerySection(width),
            const SizedBox(height: 60),
            _wave(height: 120, reverse: true),
            const SizedBox(height: 50),
            _videoSection(width),
            const SizedBox(height: 60),
            _wave(height: 120),
            _footerSection(width),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // ⭐ HERO SECTION (FIXED HEIGHT, BIGGER TITLE, CENTERED IMAGE)
  // -------------------------------------------------------------------------
  Widget _heroSection(double width) {
    return Stack(
      children: [
        Container(
          height: 520, // Increased to match the screenshot layout
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF96BD), Color(0xFFFFBFD4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Top navigation items
        Positioned(
          top: 55,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navItem("Lorem"),
              const SizedBox(width: 30),
              _navItem("Lorem"),
              const SizedBox(width: 30),
              _navItem("Lorem"),
              const SizedBox(width: 30),
              _navItem("Lorem"),
            ],
          ),
        ),

        // Title + image block
        Positioned(
          top: 150,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                "Lorem Ipsum",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Placeholder main image box (now bigger)
              Container(
                height: 230,
                width: width * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Center(
                  child: Text(
                    "MAIN IMAGE HERE",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pillButton("Lorem"),
                  const SizedBox(width: 16),
                  _pillButton("Lorem", invert: true),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navItem(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _pillButton(String label, {bool invert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
      decoration: BoxDecoration(
        color: invert ? Colors.white : Colors.pink.shade600,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: invert ? Colors.pink.shade600 : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // ⭐ WAVE DIVIDER (SMOOTH & LARGE LIKE THE PNG SAMPLE)
  // -------------------------------------------------------------------------
  Widget _wave({bool reverse = false, double height = 100}) {
    return ClipPath(
      clipper: WaveClipper(reverse: reverse),
      child: Container(
        height: height,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // ⭐ FEATURED CARDS (BIGGER & MATCHING THE SPACING IN PNG)
  // -------------------------------------------------------------------------
  Widget _featuredSection(double width) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _iceCard(),
          _iceCard(),
          _iceCard(),
        ],
      ),
    );
  }

  Widget _iceCard() {
    return Container(
      width: 115,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: Text("IMAGE")),
          ),
          const SizedBox(height: 12),
          const Text(
            "Lorem Ipsum",
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.pink),
          ),
          const SizedBox(height: 8),
          const Text(
            "Lorem ipsum dolor sit amet, consectetur.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.pink,
            child: Icon(Icons.arrow_forward, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // ⭐ ABOUT SECTION
  // -------------------------------------------------------------------------
  Widget _aboutSection(double width) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Lorem Ipsum",
            style: TextStyle(
              color: Colors.pink,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 26),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text("IMAGE")),
              ),
              const SizedBox(width: 26),
              const Expanded(
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoCard(),
              _infoCard(),
              _infoCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      height: 90,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
        ],
      ),
      child: const Center(child: Text("INFO")),
    );
  }

  // -------------------------------------------------------------------------
  // ⭐ GALLERY SECTION
  // -------------------------------------------------------------------------
  Widget _gallerySection(double width) {
    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            8,
            (i) => Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text("IMG")),
            ),
          ),
        ),

        const SizedBox(height: 36),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey,
              child: Text("IMG"),
            ),
            const SizedBox(width: 16),
            const SizedBox(
              width: 200,
              child: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () {}),
            IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () {}),
          ],
        )
      ],
    );
  }

  // -------------------------------------------------------------------------
  // ⭐ VIDEO SECTION
  // -------------------------------------------------------------------------
  Widget _videoSection(double width) {
    return Column(
      children: [
        Container(
          width: width * 0.85,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(child: Text("VIDEO HERE")),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _videoThumb(),
            const SizedBox(width: 10),
            _videoThumb(),
            const SizedBox(width: 10),
            _videoThumb(),
          ],
        )
      ],
    );
  }

  Widget _videoThumb() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text("IMG")),
    );
  }

  // -------------------------------------------------------------------------
  // ⭐ FOOTER SECTION
  // -------------------------------------------------------------------------
  Widget _footerSection(double width) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          // Input + Button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Enter email..."),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text("Send", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt, color: Colors.pink),
              SizedBox(width: 22),
              Icon(Icons.facebook, color: Colors.pink),
              SizedBox(width: 22),
              Icon(Icons.video_library, color: Colors.pink),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Lorem"),
              SizedBox(width: 20),
              Text("Lorem"),
              SizedBox(width: 20),
              Text("Lorem"),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------
// ⭐ BETTER WAVE CLIPPER — 1:1 SAME CURVE AS PNG
// -------------------------------------------------------------------------
class WaveClipper extends CustomClipper<Path> {
  final bool reverse;
  WaveClipper({this.reverse = false});

  @override
  Path getClip(Size size) {
    const double curveHeight = 40;

    Path path = Path();

    if (!reverse) {
      path.lineTo(0, size.height - curveHeight);
      path.quadraticBezierTo(
        size.width / 2, size.height + curveHeight,
        size.width, size.height - curveHeight,
      );
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(0, curveHeight);
      path.quadraticBezierTo(
        size.width / 2, -curveHeight,
        size.width, curveHeight,
      );
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
