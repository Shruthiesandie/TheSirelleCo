import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as fg;
import 'package:rive/rive.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage>
    with SingleTickerProviderStateMixin {
  // animation controllers
  late AnimationController fadeController;
  late Animation<double> fadeAnim;

  // floating mascot controller
  late AnimationController floatController;
  late Animation<double> floatAnim;

  // glowing border controller
  late AnimationController glowController;
  late Animation<double> glowAnim;

  // confetti
  late ConfettiController confettiController;

  // membership state
  bool isYearly = false;
  bool showCoupon = false;
  bool isMember = false;

  // coupon text controller
  final TextEditingController couponController = TextEditingController();

  // persistence key
  static const String _prefKeyMember = "is_premium_member";

  @override
  void initState() {
    super.initState();

    // Fade-in
    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    fadeAnim =
        CurvedAnimation(parent: fadeController, curve: Curves.easeOutCubic);
    fadeController.forward();

    // Floating mascot - loops up & down
    floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    floatAnim = Tween<double>(begin: -6.0, end: 6.0)
        .chain(CurveTween(curve: Curves.easeInOutSine))
        .animate(floatController);
    floatController.repeat(reverse: true);

    // Glowing border - pulse
    glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    glowAnim = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(glowController);
    glowController.repeat(reverse: true);

    // Confetti
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Load membership status
    _loadMembershipStatus();
  }

  Future<void> _loadMembershipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefKeyMember) ?? false;
    setState(() => isMember = saved);
  }

  Future<void> _saveMembershipStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyMember, value);
    setState(() => isMember = value);
  }

  @override
  void dispose() {
    fadeController.dispose();
    floatController.dispose();
    glowController.dispose();
    confettiController.dispose();
    couponController.dispose();
    super.dispose();
  }

  void _activateMembership() {
    // Simulate successful activation: save, confetti, snackbar
    _saveMembershipStatus(true);
    confettiController.play();
    Navigator.pop(context); // close bottom sheet if open
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Membership Activated! Enjoy discounts 🎉")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF5FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            "Premium Membership",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: isMember ? 1.0 : 0.0,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade600,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.shade600.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.workspace_premium_rounded,
                              size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            "Member",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            _background(),
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 6),
                  // Floating Rive mascot (3D-like feel via rotate + scale)
                  AnimatedBuilder(
                    animation: floatController,
                    builder: (context, child) {
                      final dy = floatAnim.value;
                      final tilt = math.sin(floatController.value * 2 * math.pi) * 0.02;
                      final scale = 1.0 + (math.cos(floatController.value * 2 * math.pi) * 0.02);
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: Transform.rotate(
                          angle: tilt,
                          child: Transform.scale(scale: scale, child: child),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 160,
                      child: const RiveAnimation.asset(
                        "assets/mascot.riv",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  _header(),
                  const SizedBox(height: 12),

                  _toggleSwitch(),
                  const SizedBox(height: 28),

                  // GLASSMORPHISM + GLOWING BORDER CARD
                  AnimatedBuilder(
                    animation: glowController,
                    builder: (context, _) {
                      final glowVal = glowAnim.value;
                      return Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated glowing shadow (bigger, diffused)
                            Container(
                              width: double.infinity,
                              height: null,
                              margin: const EdgeInsets.symmetric(horizontal: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.pinkAccent.withOpacity(0.14 * (0.6 + glowVal * 0.8)),
                                    blurRadius: 40 + glowVal * 20,
                                    spreadRadius: 2 + glowVal * 4,
                                    offset: const Offset(0, 14),
                                  ),
                                  BoxShadow(
                                    color:
                                        Colors.purpleAccent.withOpacity(0.06 * (0.6 + glowVal)),
                                    blurRadius: 60 + glowVal * 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                            ),

                            // Glass card
                            ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(26),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.14),
                                      width: 1.0,
                                    ),
                                    gradient: fg.LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.06),
                                        Colors.white.withOpacity(0.03),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title row with glowing outline
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // small emblem with gradient
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: fg.LinearGradient(
                                                colors: [
                                                  Colors.pinkAccent.shade100,
                                                  const Color(0xFFB97BFF),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.pinkAccent.withOpacity(0.18 * (0.8 + glowVal)),
                                                  blurRadius: 18 + glowVal * 8,
                                                  offset: const Offset(0, 8),
                                                )
                                              ],
                                            ),
                                            child: const Icon(Icons.workspace_premium_rounded,
                                                color: Colors.white, size: 28),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Premium Membership",
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  isYearly ? "Best value — billed yearly" : "Billed monthly",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white.withOpacity(0.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Glowing pill that shows discount
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(999),
                                              gradient: fg.LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.12),
                                                  Colors.white.withOpacity(0.06),
                                                ],
                                              ),
                                              border: Border.all(
                                                  color: Colors.white.withOpacity(0.12)),
                                            ),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: "15%",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w800,
                                                          color: Colors.pink.shade50,
                                                          fontSize: 16)),
                                                  TextSpan(
                                                      text: " OFF",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white.withOpacity(0.95),
                                                          fontWeight: FontWeight.w700)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 18),

                                      Text(
                                        isYearly ? "₹3499 / year" : "₹399 / month",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Benefits (white text)
                                      _benefit("Flat 15% OFF on all orders"),
                                      _benefit("Free delivery on every order"),
                                      _benefit("Early access to new drops"),
                                      _benefit("Exclusive member-only discounts"),
                                      _benefit("Faster customer support"),

                                      const SizedBox(height: 6),

                                      // Join/Upgrade small row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: _showJoinBottomSheet,
                                              child: Container(
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  gradient: fg.LinearGradient(
                                                    colors: [
                                                      Colors.pinkAccent,
                                                      const Color(0xFFB97BFF)
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.pinkAccent.withOpacity(0.18),
                                                      blurRadius: 16,
                                                      offset: const Offset(0, 8),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    isMember ? "You're a Member" : "Join Membership",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Small restore / toggle display (if already member, allow "Manage")
                                          if (isMember)
                                            GestureDetector(
                                              onTap: () {
                                                // quick toggle for demo: un-save membership
                                                _saveMembershipStatus(false);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                      content:
                                                          Text("Membership removed")),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.06),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(Icons.more_horiz,
                                                    color: Colors.white),
                                              ),
                                            ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 26),

                  _couponButton(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: showCoupon ? _couponInput() : const SizedBox(),
                  ),

                  const SizedBox(height: 34),
                ],
              ),
            ),

            // Confetti widget placed on top center
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.02,
                numberOfParticles: 30,
                maxBlastForce: 20,
                minBlastForce: 6,
                gravity: 0.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Text(
          "Unlock Exclusive Benefits",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.pink.shade600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Become a premium member and enjoy better savings.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
      ],
    );
  }

  Widget _toggleSwitch() {
    return GestureDetector(
      onTap: () => setState(() => isYearly = !isYearly),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toggleOption("Monthly", !isYearly),
            _toggleOption("Yearly", isYearly),
          ],
        ),
      ),
    );
  }

  Widget _toggleOption(String label, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.pinkAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _couponButton() {
    return GestureDetector(
      onTap: () => setState(() => showCoupon = !showCoupon),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer, color: Colors.pink.shade600, size: 22),
          const SizedBox(width: 6),
          Text(
            showCoupon ? "Hide Coupon" : "Have a coupon?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.pink.shade600,
            ),
          )
        ],
      ),
    );
  }

  Widget _couponInput() {
    return Container(
      key: const ValueKey("coupon"),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: couponController,
              decoration: const InputDecoration(
                hintText: "Enter coupon code",
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              final code = couponController.text.trim();
              if (code.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a coupon code")),
                );
                return;
              }
              // Example: simple coupon handling (replace with real logic)
              if (code.toUpperCase() == "WELCOME15") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Coupon Applied: 15% OFF")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid coupon")),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Apply",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showJoinBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Activate Premium Membership",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  isYearly ? "₹3499 / year" : "₹399 / month",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.pink.shade600,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Unlock exclusive perks, extra savings and free delivery.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _activateMembership,
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: fg.LinearGradient(
                        colors: [Colors.pinkAccent, const Color(0xFFB97BFF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "Join Now",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (!isMember)
                  TextButton(
                    onPressed: () {
                      // Close sheet - show a quick demo message
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "You can pay using your preferred payment gateway.")));
                    },
                    child: const Text("Choose another payment method"),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _background() {
    return Stack(
      children: [
        Positioned(
          left: -120,
          top: -60,
          child: _blurCircle(260, Colors.pinkAccent.withOpacity(0.20)),
        ),
        Positioned(
          right: -90,
          bottom: -60,
          child: _blurCircle(240, Colors.purpleAccent.withOpacity(0.16)),
        ),
        Positioned(
          left: 20,
          bottom: 80,
          child: _blurCircle(120, Colors.amberAccent.withOpacity(0.06)),
        ),
      ],
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(),
      ),
    );
  }
}
