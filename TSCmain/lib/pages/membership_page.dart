import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as fg;

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage>
    with SingleTickerProviderStateMixin {
  int selectedPlan = 1;

  late AnimationController fadeController;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fadeAnim =
        CurvedAnimation(parent: fadeController, curve: Curves.easeOutCubic);

    fadeController.forward();
  }

  @override
  void dispose() {
    fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF4F7),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            "Membership",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Stack(
          children: [
            _background(),
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _header(),
                  const SizedBox(height: 24),

                  // Plans
                  _planCard(
                    index: 0,
                    title: "Basic",
                    price: "₹199 / month",
                    benefits: [
                      "Access to basic features",
                      "Email support",
                      "Limited rewards"
                    ],
                    colors: [
                      const Color(0xFFFFE4E4),
                      const Color(0xFFFFD1D1),
                    ],
                    icon: Icons.favorite_border,
                  ),
                  const SizedBox(height: 20),

                  _planCard(
                    index: 1,
                    title: "Silver",
                    price: "₹399 / month",
                    benefits: [
                      "All Basic features",
                      "Priority support",
                      "Monthly discount coupons"
                    ],
                    colors: [
                      const Color(0xFFE3D7FF),
                      const Color(0xFFC7B5FF),
                    ],
                    icon: Icons.stars_rounded,
                  ),
                  const SizedBox(height: 20),

                  _planCard(
                    index: 2,
                    title: "Premium",
                    price: "₹799 / month",
                    benefits: [
                      "All Silver features",
                      "Exclusive drops",
                      "VIP customer care",
                      "Special give-aways"
                    ],
                    colors: [
                      const Color(0xFFFFD5F2),
                      const Color(0xFFFFAEEA),
                    ],
                    icon: Icons.workspace_premium_rounded,
                  ),
                  const SizedBox(height: 34),

                  _continueButton(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------
  Widget _header() {
    return Column(
      children: [
        Text(
          "Choose your plan",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.pink.shade600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Unlock premium benefits and exclusive rewards",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PLAN CARD
  // ------------------------------------------------------------
  Widget _planCard({
    required int index,
    required String title,
    required String price,
    required List<String> benefits,
    required List<Color> colors,
    required IconData icon,
  }) {
    bool active = selectedPlan == index;

    return AnimatedScale(
      scale: active ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: () => setState(() => selectedPlan = index),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: fg.LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: colors.last.withOpacity(0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 38, color: Colors.black87),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 14),

              // Benefits list
              ...benefits.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.black87, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          b,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CONTINUE BUTTON
  // ------------------------------------------------------------
  Widget _continueButton() {
    return GestureDetector(
      onTap: () {
        // Handle confirm action here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Selected: ${["Basic", "Silver", "Premium"][selectedPlan]} Plan",
            ),
          ),
        );
      },
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: fg.LinearGradient(
            colors: [
              Colors.pinkAccent,
              const Color(0xFFB97BFF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Continue",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BACKGROUND WAVES + ORBS
  // ------------------------------------------------------------
  Widget _background() {
    return Stack(
      children: [
        Positioned(
          left: -80,
          top: -40,
          child: _blurCircle(200, Colors.pinkAccent.withOpacity(0.25)),
        ),
        Positioned(
          right: -70,
          bottom: -40,
          child: _blurCircle(220, Colors.purpleAccent.withOpacity(0.20)),
        ),
      ],
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(),
      ),
    );
  }
}
