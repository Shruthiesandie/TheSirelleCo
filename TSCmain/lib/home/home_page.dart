// lib/pages/ice_cream_landing_page.dart
import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _heroSection(),
            _wave(),
            _featuredCardsSection(),
            _wave(reverse: true),
            _aboutSection(),
            _wave(),
            _galleryTestimonialsSection(),
            _wave(reverse: true),
            _videoSection(),
            _wave(),
            _footerSection(),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // ⭐ SECTION 1 — HERO HEADER
  // -------------------------------------------------------------
  Widget _heroSection() {
    return Stack(
      children: [
        Container(
          height: 420,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFAFCF), Color(0xFFFFC8DA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navItem("Lorem"),
              const SizedBox(width: 26),
              _navItem("Lorem"),
              const SizedBox(width: 26),
              _navItem("Lorem"),
              const SizedBox(width: 26),
              _navItem("Lorem"),
            ],
          ),
        ),

        Positioned(
          top: 130,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Text(
                "Lorem Ipsum",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // 🍓 IMAGE PLACEHOLDER
              Container(
                height: 180,
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text("MAIN IMAGE HERE"),
                ),
              ),

              const SizedBox(height: 22),

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

  Widget _navItem(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _pillButton(String label, {bool invert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: invert ? Colors.white : Colors.pink,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: invert ? Colors.pink : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // ⭐ REUSABLE WAVE DIVIDER
  // -------------------------------------------------------------
  Widget _wave({bool reverse = false}) {
    return ClipPath(
      clipper: WaveClipper(reverse: reverse),
      child: Container(
        height: 80,
        color: Colors.white,
      ),
    );
  }

  // -------------------------------------------------------------
  // ⭐ SECTION 2 — FEATURED ICE CREAM CARDS
  // -------------------------------------------------------------
  Widget _featuredCardsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _iceCard(),
              _iceCard(),
              _iceCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iceCard() {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 6),
            color: Colors.pink.withOpacity(0.2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ice cream image placeholder
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: Text("IMAGE")),
          ),
          const SizedBox(height: 10),
          const Text(
            "Lorem Ipsum",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink),
          ),
          const SizedBox(height: 6),
          const Text(
            "Lorem ipsum dolor sit amet, consectetur.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 14,
            backgroundColor: Colors.pink,
            child: Icon(Icons.arrow_forward, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ⭐ SECTION 3 — ABOUT SECTION
  // -------------------------------------------------------------
  Widget _aboutSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(26),
      child: Column(
        children: [
          const Text(
            "Lorem Ipsum",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 26),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Jar image placeholder
              Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.pink.shade100,
                ),
                child: const Center(child: Text("IMAGE")),
              ),

              const SizedBox(width: 20),

              // description
              const Expanded(
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.",
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
              )
            ],
          ),

          const SizedBox(height: 30),

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
      width: 100,
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(child: Text("INFO")),
    );
  }

  // -------------------------------------------------------------
  // ⭐ SECTION 4 — GALLERY + TESTIMONIALS
  // -------------------------------------------------------------
  Widget _galleryTestimonialsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(26),
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              8,
              (i) => Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text("IMG")),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // testimonial
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                child: Text("IMG"),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ⭐ SECTION 5 — VIDEO PREVIEW
  // -------------------------------------------------------------
  Widget _videoSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          // big video block
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Center(child: Text("VIDEO HERE")),
          ),

          const SizedBox(height: 20),

          // side thumbnails
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _thumbBlock(),
              const SizedBox(width: 10),
              _thumbBlock(),
              const SizedBox(width: 10),
              _thumbBlock(),
            ],
          )
        ],
      ),
    );
  }

  Widget _thumbBlock() {
    return Container(
      width: 70,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text("IMG")),
    );
  }

  // -------------------------------------------------------------
  // ⭐ SECTION 6 — FOOTER
  // -------------------------------------------------------------
  Widget _footerSection() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      child: Column(
        children: [
          // Input + Button
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  height: 50,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Enter email..."),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text("Send", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Social icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt, color: Colors.pink),
              SizedBox(width: 20),
              Icon(Icons.facebook, color: Colors.pink),
              SizedBox(width: 20),
              Icon(Icons.video_library, color: Colors.pink),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Lorem"), SizedBox(width: 18),
              Text("Lorem"), SizedBox(width: 18),
              Text("Lorem"),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// ⭐ WAVE CLIPPER
// ------------------------------------------------------------------
class WaveClipper extends CustomClipper<Path> {
  final bool reverse;
  WaveClipper({this.reverse = false});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    if (!reverse) {
      path.lineTo(0, size.height - 30);
      path.quadraticBezierTo(size.width / 2, size.height + 30, size.width, size.height - 30);
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(0, 30);
      path.quadraticBezierTo(size.width / 2, -30, size.width, 30);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
