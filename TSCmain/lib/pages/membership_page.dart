import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as fg;
import 'package:rive/rive.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage>
    with SingleTickerProviderStateMixin {
  late AnimationController fadeController;
  late Animation<double> fadeAnim;

  bool isYearly = false; // Monthly / Yearly toggle
  bool showCoupon = false; // Coupon section toggle

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
                  _riveMascot(),
                  const SizedBox(height: 10),

                  _header(),
                  const SizedBox(height: 12),

                  _toggleSwitch(),
                  const SizedBox(height: 28),

                  _membershipCard(), // ⭐ Only ONE card

                  const SizedBox(height: 26),

                  _couponButton(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: showCoupon ? _couponInput() : const SizedBox(),
                  ),

                  const SizedBox(height: 34),

                  _continueButton(),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // RIVE MASCOT
  // ------------------------------------------------------------
  Widget _riveMascot() {
    return SizedBox(
      height: 160,
      child: const RiveAnimation.asset(
        "assets/mascot.riv",
        fit: BoxFit.contain,
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

  // ------------------------------------------------------------
  // MONTHLY/YEARLY TOGGLE
  // ------------------------------------------------------------
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

  // ------------------------------------------------------------
  // ⭐ SINGLE MEMBERSHIP CARD
  // ------------------------------------------------------------
  Widget _membershipCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: fg.LinearGradient(
          colors: [
            const Color(0xFFFFD8F0),
            const Color(0xFFE7B8FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.35),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
            const  Icon(Icons.workspace_premium_rounded,
                size: 38, color: Colors.white),
              const SizedBox(width: 12),
              const Text(
                "Premium Membership",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            isYearly ? "₹3499 / year" : "₹399 / month",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          // Benefits
          _benefit("Flat 15% OFF on all orders"),
          _benefit("Free delivery on every order"),
          _benefit("Early access to new drops"),
          _benefit("Exclusive member-only discounts"),
          _benefit("Faster customer support"),
        ],
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // COUPON UI
  // ------------------------------------------------------------
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Enter coupon code",
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Apply",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CONTINUE (Join Membership)
  // ------------------------------------------------------------
  Widget _continueButton() {
    return GestureDetector(
      onTap: _showJoinBottomSheet,
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
            "Join Membership",
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
  // BOTTOM SHEET
  // ------------------------------------------------------------
  void _showJoinBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
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
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Membership Activated!"),
                    ),
                  );
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: fg.LinearGradient(
                      colors: [
                        Colors.pinkAccent,
                        const Color(0xFFB97BFF)
                      ],
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
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // BACKGROUND ORBS
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
