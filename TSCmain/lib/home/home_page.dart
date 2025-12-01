// lib/pages/ice_cream_landing_page.dart
import 'dart:math';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class HomePageState extends State<IceCreamLandingPageAnimated> with TickerProviderStateMixin {
  late final AnimationController _mainBobController; // main image bobbing
  late final AnimationController _floatController; // fruit/choco floating
  late final AnimationController _glowController; // glow pulse
  late final Animation<double> _bobAnim;
  late final Animation<double> _floatAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    // main bobbing: gentle spring-like loop
    _mainBobController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _bobAnim = CurvedAnimation(parent: _mainBobController, curve: const Cubic(0.22, 1.0, 0.36, 1.0));
    _mainBobController.repeat(reverse: true);

    // floating items: slower drifting loop (used with sin)
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _floatAnim = CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine);
    _floatController.repeat();

    // glow pulse behind main image
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _glowAnim = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainBobController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // helper: small sinusoidal offset
  double sinOffset(double seed, double amplitude, double progress) {
    return sin((progress + seed) * 2 * pi) * amplitude;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F4),
      body: SafeArea(
        child: Stack(
          children: [
            // Page content scrollable
            SingleChildScrollView(
              child: Column(
                children: [
                  // HERO + big stacks
                  SizedBox(
                    height: 520,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // pink gradient background
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF96BD), Color(0xFFFFBFD4)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),

                        // floating fruits/chocolate/popsicle positioned around hero
                        // We use AnimatedBuilder to move them via sin offsets
                        AnimatedBuilder(
                          animation: Listenable.merge([_floatController, _mainBobController, _glowController]),
                          builder: (context, _) {
                            final p = _floatController.value;
                            final bob = _bobAnim.value;
                            final glow = _glowAnim.value;

                            // Fruit 1 (left top)
                            final fruit1Y = -40 + sinOffset(0.2, 8, p);
                            final fruit1X = -w * 0.16 + sinOffset(0.6, 10, p);

                            // Chocolate (top-right)
                            final chocY = -20 + sinOffset(0.8, 6, p);
                            final chocX = w * 0.28 + sinOffset(0.1, 8, p);

                            // Popsicle (behind main image, bottom-left)
                            final popY = 120 + sinOffset(1.2, 10, p);
                            final popX = -w * 0.18 + sinOffset(0.3, 6, p);

                            return Stack(
                              children: [
                                // small fruit top-left
                                Positioned(
                                  top: 30 + fruit1Y,
                                  left: 26 + fruit1X,
                                  child: Transform.rotate(
                                    angle: 0.12 * sin(2 * pi * p),
                                    child: _floatingFruit(icon: Icons.apple, label: "Straw", size: 48),
                                  ),
                                ),

                                // chocolate piece top-right
                                Positioned(
                                  top: 20 + chocY,
                                  right: 32 - chocX,
                                  child: Transform.rotate(
                                    angle: -0.12 + 0.08 * sin(2 * pi * p),
                                    child: _floatingChocolate(size: 52),
                                  ),
                                ),

                                // pink popsicle behind main (slightly rotated)
                                Positioned(
                                  bottom: 40 + popY * 0.0,
                                  left: 24 + popX,
                                  child: Transform.rotate(
                                    angle: -0.25 + 0.1 * sin(2 * pi * p),
                                    child: Opacity(
                                      opacity: 0.95,
                                      child: _floatingPopsicle(height: 150, width: 60),
                                    ),
                                  ),
                                ),

                                // soft circular glow behind main image (animated)
                                Positioned(
                                  top: 150 - (20 * glow),
                                  child: SizedBox(
                                    width: w,
                                    child: Center(
                                      child: Container(
                                        height: 180 + 30 * glow,
                                        width: 360 + 30 * glow,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.pink.withOpacity(0.22 * (0.6 + glow * 0.6)),
                                              Colors.transparent,
                                            ],
                                            radius: 0.7,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // Top center: nav items
                        Positioned(
                          top: 18,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _navItem("Lorem"),
                              const SizedBox(width: 24),
                              _navItem("Lorem"),
                              const SizedBox(width: 24),
                              _navItem("Lorem"),
                            ],
                          ),
                        ),

                        // Title + main image + pills
                        Positioned(
                          top: 140,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              const Text(
                                "Lorem Ipsum",
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // MAIN IMAGE PLACEHOLDER with bobbing animation
                              AnimatedBuilder(
                                animation: _mainBobController,
                                builder: (context, child) {
                                  final bob = (sin(_mainBobController.value * 2 * pi) * 6);
                                  return Transform.translate(
                                    offset: Offset(0, bob),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  height: 220,
                                  width: w * 0.78,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pink.withOpacity(0.12),
                                        blurRadius: 22,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Center(child: Text("MAIN IMAGE HERE")),
                                ),
                              ),

                              const SizedBox(height: 28),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _pillButton("Lorem"),
                                  const SizedBox(width: 12),
                                  _pillButton("Lorem", invert: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Wave divider
                  _wave(height: 110),

                  const SizedBox(height: 28),

                  // FEATURED CARDS row (3 cards)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _featureCard(),
                        _featureCard(),
                        _featureCard(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),
                  _wave(height: 120, reverse: true),
                  const SizedBox(height: 36),

                  // ABOUT section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        const Text(
                          "Lorem Ipsum",
                          style: TextStyle(color: Colors.pink, fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.pink.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(child: Text("IMG")),
                            ),
                            const SizedBox(width: 18),
                            const Expanded(
                              child: Text(
                                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.",
                                style: TextStyle(fontSize: 14),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [_infoCard(), _infoCard(), _infoCard()],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  _wave(height: 130),
                  const SizedBox(height: 24),

                  // GALLERY grid (simple)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                      children: List.generate(9, (i) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Text("IMG")),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 36),
                  _wave(height: 120, reverse: true),
                  const SizedBox(height: 36),

                  // Video preview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.pink.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(child: Text("VIDEO PREVIEW")),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_videoThumb(), const SizedBox(width: 12), _videoThumb(), const SizedBox(width: 12), _videoThumb()],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30)),
                                child: const Align(alignment: Alignment.centerLeft, child: Text("Enter email...")),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(30)),
                              child: const Text("Send", style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.camera_alt, color: Colors.pink), SizedBox(width: 16), Icon(Icons.facebook, color: Colors.pink), SizedBox(width: 16), Icon(Icons.video_library, color: Colors.pink)]),
                        const SizedBox(height: 18),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Text("Lorem"), SizedBox(width: 18), Text("Lorem"), SizedBox(width: 18), Text("Lorem")]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),

            // floating arc menu + other overlays could go here (kept separate)
          ],
        ),
      ),
    );
  }

  // ------------------- UI small helpers -------------------
  Widget _navItem(String label) {
    return Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700));
  }

  Widget _pillButton(String label, {bool invert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: invert ? Colors.white : Colors.pink.shade600,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(label, style: TextStyle(color: invert ? Colors.pink.shade600 : Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _wave({bool reverse = false, double height = 80}) {
    return ClipPath(
      clipper: _WaveClipper(reverse: reverse),
      child: Container(height: height, color: Colors.white),
    );
  }

  Widget _featureCard() {
    return Container(
      width: 115,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(children: [
        Container(height: 78, decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(16)), child: const Center(child: Text("IMAGE"))),
        const SizedBox(height: 10),
        const Text("Lorem Ipsum", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.pink)),
        const SizedBox(height: 6),
        const Text("Short description", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 10),
        const CircleAvatar(radius: 16, backgroundColor: Colors.pink, child: Icon(Icons.arrow_forward, size: 16, color: Colors.white)),
      ]),
    );
  }

  Widget _infoCard() {
    return Container(width: 100, height: 86, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]), child: const Center(child: Text("INFO")));
  }

  Widget _videoThumb() {
    return Container(width: 62, height: 62, decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text("IMG")));
  }

  // Floating fruit widget (replace with real image later)
  Widget _floatingFruit({required IconData icon, required String label, double size = 48}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(size / 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
      child: Center(child: Icon(icon, color: Colors.pink, size: size * 0.5)),
    );
  }

  // Floating chocolate (placeholder)
  Widget _floatingChocolate({double size = 52}) {
    return Container(
      height: size,
      width: size * 0.7,
      decoration: BoxDecoration(color: Colors.brown.shade300, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 6))]),
      child: const Center(child: Text("Choc", style: TextStyle(color: Colors.white))),
    );
  }

  // Popsicle (placeholder)
  Widget _floatingPopsicle({double width = 60, double height = 150}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF9BC4), Color(0xFFFF6F9E)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 6))],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height * 0.22,
          width: width * 0.24,
          decoration: BoxDecoration(color: Colors.brown.shade300, borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}

// Simple wave clipper used across the page
class _WaveClipper extends CustomClipper<Path> {
  final bool reverse;
  _WaveClipper({this.reverse = false});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (!reverse) {
      path.lineTo(0, size.height - 40);
      path.quadraticBezierTo(size.width / 4, size.height + 20, size.width / 2, size.height - 18);
      path.quadraticBezierTo(size.width * 3 / 4, size.height - 56, size.width, size.height - 20);
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(0, 20);
      path.quadraticBezierTo(size.width / 4, -20, size.width / 2, 18);
      path.quadraticBezierTo(size.width * 3 / 4, 56, size.width, 20);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
