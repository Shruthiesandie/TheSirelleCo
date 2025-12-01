// lib/home/home_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Full-screen ice-cream landing page (pure landing layout)
/// Replace the placeholder containers with Image.asset(...) when you add assets.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // controllers
  late final PageController _featuredController;
  late final PageController _testimonialsController;
  late final ScrollController _galleryController;

  // small animations
  late final AnimationController _floatingController;
  late final AnimationController _heroPulseController;

  @override
  void initState() {
    super.initState();
    _featuredController = PageController(viewportFraction: 0.86, keepPage: true);
    _testimonialsController = PageController(viewportFraction: 0.92);
    _galleryController = ScrollController();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _heroPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      lowerBound: 0.96,
      upperBound: 1.04,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _featuredController.dispose();
    _testimonialsController.dispose();
    _galleryController.dispose();
    _floatingController.dispose();
    _heroPulseController.dispose();
    super.dispose();
  }

  // small helpers
  double _responsiveValue(BuildContext c, double wide, double narrow) {
    return MediaQuery.of(c).size.width > 800 ? wide : narrow;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Background pink gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE6F2), Color(0xFFFFF3F8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Top wave - hero pink band
            Column(
              children: [
                SizedBox(
                  height: isWide ? 420 : 360,
                  child: Stack(
                    children: [
                      // pink curved band (clipper)
                      ClipPath(
                        clipper: TopWaveClipper(),
                        child: Container(
                          height: isWide ? 420 : 360,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFAFCF), Color(0xFFFFD0EA)],
                              begin: Alignment(-0.9, -0.4),
                              end: Alignment(1.0, 0.8),
                            ),
                          ),
                        ),
                      ),

                      // floating decorative fruits/popsicles/chocolate
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            final t = _floatingController.value;
                            return Stack(
                              children: [
                                // small floating strawberry top-left
                                Positioned(
                                  left: 24 + sin(t * 2 * pi) * 6,
                                  top: 24 + cos(t * 2 * pi) * 8,
                                  child: _floatingFruit(size: 36, label: "🍓"),
                                ),

                                // chocolate piece
                                Positioned(
                                  right: 70 + sin(t * 1.4 * pi) * 8,
                                  top: 44 + cos(t * 1.1 * pi) * 6,
                                  child: _floatingFruit(size: 28, label: "🍫"),
                                ),

                                // popsicle behind hero (soft)
                                Positioned(
                                  right: isWide ? 60 : 24,
                                  top: isWide ? 80 : 110,
                                  child: Transform.rotate(
                                    angle: -0.16,
                                    child: Opacity(
                                      opacity: 0.12,
                                      child: _popsiclePlaceholder(width: 120, height: 240),
                                    ),
                                  ),
                                ),

                                // floating mint leaf
                                Positioned(
                                  left: mq.size.width * 0.22 + sin(t * 1.3 * 2 * pi) * 10,
                                  top: isWide ? 72 + cos(t * 1.7 * 2 * pi) * 6 : 120 + cos(t * 1.7 * 2 * pi) * 6,
                                  child: _floatingFruit(size: 22, label: "🌿"),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // centered nav (white text) and profile small intro
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            // nav items
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _navText("Home"),
                                const SizedBox(width: 22),
                                _navText("Flavours"),
                                const SizedBox(width: 22),
                                _navText("About"),
                                const SizedBox(width: 22),
                                _navText("Gallery"),
                                const SizedBox(width: 22),
                                _navText("Contact"),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // profile circle + intro (on right)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: _responsiveValue(context, 56, 18)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white24,
                                      child: Icon(Icons.person, color: Colors.white70),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text("Hi, I'm Sirelle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                        Text("Founder", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // HERO CONTENT: bowl of ice-cream (placeholder) + two pill buttons
                      Positioned.fill(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // main image/TX + glow + placeholder image container
                              ScaleTransition(
                                scale: _heroPulseController,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // soft glow
                                    Container(
                                      width: isWide ? 360 : 300,
                                      height: isWide ? 240 : 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        gradient: RadialGradient(
                                          colors: [Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.05)],
                                        ),
                                        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.18), blurRadius: 36, spreadRadius: 6)],
                                      ),
                                    ),

                                    // main visual placeholder (your bowl / image)
                                    _heroImagePlaceholder(width: isWide ? 360 : 300, height: isWide ? 240 : 200),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // headline + subtext + pills
                              Column(
                                children: [
                                  Text(
                                    "Creamy Strawberry Dreams",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.pink.shade900,
                                      fontSize: _responsiveValue(context, 34, 22),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Handmade scoops, whimsical toppings — made with love.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.pink.shade700.withOpacity(0.9)),
                                  ),

                                  const SizedBox(height: 14),

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                          backgroundColor: Colors.pink.shade400,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        ),
                                        child: const Text("Order Now", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                        ),
                                        child: Text("Explore", style: TextStyle(color: Colors.pink.shade600, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // MAIN PAGE CONTENT (scrollable)
            Positioned.fill(
              top: isWide ? 320 : 300,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section 2 — Featured Ice Cream Cards
                        _sectionHeading("Featured Flavours"),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: _responsiveValue(context, 380, 320),
                          child: PageView.builder(
                            controller: _featuredController,
                            itemCount: 3,
                            padEnds: true,
                            itemBuilder: (context, index) {
                              final flavors = ["Strawberry Swirl", "Classic Vanilla", "Chocolate Dream"];
                              final desc = [
                                "Fresh strawberries and creamy swirls",
                                "Simple, pure, and velvety",
                                "Rich cocoa with dark chocolate chips"
                              ];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: _flavourCard(title: flavors[index], description: desc[index], wide: isWide),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Section 3 — About
                        _sectionHeading("About Us", accent: Colors.pink.shade700),
                        const SizedBox(height: 12),
                        _aboutSection(isWide),

                        const SizedBox(height: 22),

                        // Section 4 — Gallery + Testimonials
                        _sectionHeading("Gallery"),
                        const SizedBox(height: 12),
                        _galleryGrid(context),
                        const SizedBox(height: 18),
                        _sectionHeading("What People Say"),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: PageView.builder(
                            controller: _testimonialsController,
                            itemCount: 3,
                            itemBuilder: (context, i) => _testimonialCard(i),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Section 5 — Video Preview + side thumbnails
                        _sectionHeading("Preview", accent: Colors.pink.shade700),
                        const SizedBox(height: 12),
                        _videoPreviewRow(isWide),

                        const SizedBox(height: 28),

                        // Section 6 — Footer
                        _footerSection(context, isWide),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI pieces ----------------

  // simple nav text
  Widget _navText(String text) => Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600));

  // glowing placeholder for hero image
  Widget _heroImagePlaceholder({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.88)]),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.10), blurRadius: 28, offset: const Offset(0, 10))],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // placeholder "image area"
            Container(
              width: width * 0.86,
              height: height * 0.66,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.pink.shade50,
                border: Border.all(color: Colors.white70),
              ),
              child: const Center(child: Text("YOUR HERO IMAGE", style: TextStyle(color: Colors.pink))),
            ),
          ],
        ),
      ),
    );
  }

  // small floating fruit widget
  Widget _floatingFruit({required double size, required String label}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Center(child: Text(label, style: TextStyle(fontSize: max(12, size / 2.6)))),
    );
  }

  Widget _popsiclePlaceholder({double width = 80, double height = 200}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [Colors.pink.shade200, Colors.pink.shade100]),
      ),
    );
  }

  // section heading
  Widget _sectionHeading(String title, {Color accent = Colors.pink}) {
    return Row(
      children: [
        Container(width: 6, height: 28, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6))),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.pink.shade800)),
        const Spacer(),
        // subtle pink section indicator (small stripe)
        Container(height: 8, width: 80, decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(8))),
      ],
    );
  }

  // flavour card (vertical style)
  Widget _flavourCard({required String title, required String description, required bool wide}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // waffle cone + floating toppings (placeholder)
            SizedBox(
              width: wide ? 220 : 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // placeholder for cone image
                  Container(
                    height: wide ? 180 : 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(colors: [Colors.pink.shade50, Colors.pink.shade100]),
                    ),
                    child: Center(child: Text(title, style: TextStyle(color: Colors.pink.shade700, fontWeight: FontWeight.w700))),
                  ),

                  // floating toppings
                  Positioned(top: 8, left: 20, child: _floatingFruit(size: 26, label: "🍓")),
                  Positioned(bottom: 16, right: 18, child: _floatingFruit(size: 20, label: "✨")),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.pink.shade800)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(color: Colors.black54)),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: Colors.pink.shade50.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                        child: const Text("Details", style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Container()),
                      // circular arrow button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pink.shade100,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.rotate_right, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // About section layout
  Widget _aboutSection(bool wide) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))
      ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // left: milk jar image in pink circle
          Container(
            width: wide ? 140 : 100,
            height: wide ? 140 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.pink.shade100, Colors.purple.shade50]),
              boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 12)],
            ),
            child: Center(child: Text("MILK\nJAR", textAlign: TextAlign.center, style: TextStyle(color: Colors.pink.shade700))),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("We make ice cream with care", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.pink.shade800)),
                const SizedBox(height: 8),
                const Text("Since 2010 we handcraft small-batch ice cream using local dairy and fresh fruit. Our scoops are made daily and decorated with edible toppings."),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _infoCard("Small-batch", "Handmade daily"),
                    const SizedBox(width: 10),
                    _infoCard("Natural", "No artificial flavours"),
                    const SizedBox(width: 10),
                    _infoCard("Local", "Sourced ingredients"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.pink.shade50.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
      ),
    );
  }

  // Gallery grid (rounded image tiles)
  Widget _galleryGrid(BuildContext context) {
    final columns = MediaQuery.of(context).size.width > 900 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.pink.shade50,
            child: Center(child: Text("PHOTO ${i + 1}", style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w600))),
          ),
        );
      },
    );
  }

  // Testimonial card
  Widget _testimonialCard(int index) {
    final names = ["Maya", "Arjun", "Leah"];
    final quotes = [
      "Best ice cream ever — creamy and dreamy!",
      "I can't stop ordering. Fresh and delicious.",
      "The toppings are on another level. Love it!"
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))
      ]),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundColor: Colors.pink.shade50, child: Text(names[index][0])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(names[index], style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(quotes[index], style: const TextStyle(color: Colors.black54)),
            ]),
          ),
        ],
      ),
    );
  }

  // Video preview mock (center rectangle + vertical thumbnails)
  Widget _videoPreviewRow(bool wide) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: wide ? 220 : 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: const DecorationImage(
                    // placeholder: replace with your textured background image
                    image: AssetImage(''), // leave blank; replace later
                    fit: BoxFit.cover,
                  ),
                  color: Colors.pink.shade50,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Lorem Ipsum", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.95), shadows: [
                        const Shadow(blurRadius: 10, color: Colors.black38, offset: Offset(0, 4))
                      ])),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.9)),
                        child: IconButton(onPressed: () {}, icon: const Icon(Icons.play_arrow, size: 36, color: Colors.pink)),
                      ),
                    ],
                  ),
                ),
              ),

              // soft overlay for emboss
              Positioned(
                left: 18,
                top: 12,
                child: Opacity(
                  opacity: 0.06,
                  child: Container(width: 120, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // thumbnails column
        Expanded(
          flex: 1,
          child: Column(
            children: List.generate(3, (i) => Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(color: Colors.pink.shade100, child: Center(child: Text("Thumb ${i + 1}"))),
              ),
            ))),
          ),
        ),
      ],
    );
  }

  // Footer
  Widget _footerSection(BuildContext context, bool wide) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // input + button row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: const [
                    Icon(Icons.email, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(child: TextField(decoration: InputDecoration.collapsed(hintText: "Enter your email"))),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Subscribe", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // social + nav links
          Row(
            children: [
              // social icons
              Row(children: [
                _socialIcon(Icons.camera_alt),
                const SizedBox(width: 10),
                _socialIcon(Icons.facebook),
                const SizedBox(width: 10),
                _socialIcon(Icons.play_circle_fill),
              ]),
              const Spacer(),
              Row(children: [
                _footerLink("Privacy"),
                const SizedBox(width: 12),
                _footerLink("Terms"),
                const SizedBox(width: 12),
                _footerLink("Contact"),
              ]),
            ],
          ),

          const SizedBox(height: 12),

          // bottom navigation links
          Wrap(
            spacing: 12,
            children: [
              Text("© ${DateTime.now().year} Sirelle Co.", style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Icon(icon, size: 18, color: Colors.pink),
    );
  }

  Widget _footerLink(String text) => Text(text, style: TextStyle(color: Colors.pink.shade700, fontWeight: FontWeight.w600));

} // end HomePage

// ---------------------------
// Custom Clippers (waves)
// ---------------------------

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // top left -> bottom left curve -> top right curve
    path.lineTo(0, size.height * 0.72);
    path.quadraticBezierTo(size.width * 0.12, size.height * 0.86, size.width * 0.28, size.height * 0.78);
    path.quadraticBezierTo(size.width * 0.52, size.height * 0.68, size.width * 0.72, size.height * 0.78);
    path.quadraticBezierTo(size.width * 0.88, size.height * 0.86, size.width, size.height * 0.72);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
