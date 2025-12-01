import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as fg;
import 'package:rive/rive.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage>
    with TickerProviderStateMixin {
  // ------------------------------------------------------------
  // Animation controllers
  // ------------------------------------------------------------
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  late final ConfettiController _confetti;

  // ------------------------------------------------------------
  // UI state
  // ------------------------------------------------------------
  bool isYearly = false;
  bool showCoupon = false;
  bool isMember = false;

  final TextEditingController _couponController = TextEditingController();

  // Shared prefs key
  static const String _memberKey = "premium_member";

  @override
  void initState() {
    super.initState();

    _initFadeAnimation();
    _initFloatingMascot();
    _initGlowAnimation();

    _confetti = ConfettiController(duration: const Duration(seconds: 2));

    _loadMembershipStatus();
  }

  // ------------------------------------------------------------
  // Init animations
  // ------------------------------------------------------------
  void _initFadeAnimation() {
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();
  }

  void _initFloatingMascot() {
    _floatController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

    _floatAnim = Tween<double>(begin: -6, end: 6)
        .chain(CurveTween(curve: Curves.easeInOutSine))
        .animate(_floatController);

    _floatController.repeat(reverse: true);
  }

  void _initGlowAnimation() {
    _glowController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

    _glowAnim = Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_glowController);

    _glowController.repeat(reverse: true);
  }

  // ------------------------------------------------------------
  // Load & save membership status
  // ------------------------------------------------------------
  Future<void> _loadMembershipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isMember = prefs.getBool(_memberKey) ?? false);
  }

  Future<void> _saveMembershipStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_memberKey, value);
    setState(() => isMember = value);
  }

  // ------------------------------------------------------------
  // Activate membership
  // ------------------------------------------------------------
  void _activateMembership() {
    _saveMembershipStatus(true);
    _confetti.play();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Membership Activated! 🎉")),
    );
  }

  // ------------------------------------------------------------
  // Dispose
  // ------------------------------------------------------------
  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _confetti.dispose();
    _couponController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF5FA),
        appBar: _appBar(),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            _background(),
            _mainContent(),
            _confettiWidget(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // AppBar
  // ------------------------------------------------------------
  AppBar _appBar() {
    return AppBar(
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
        if (isMember) _memberBadge(),
      ],
    );
  }

  Widget _memberBadge() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.pink.shade600,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade600.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.workspace_premium_rounded, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text("Member",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Main content scroll
  // ------------------------------------------------------------
  Widget _mainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _floatingMascot(),
          const SizedBox(height: 6),
          _header(),
          const SizedBox(height: 12),
          _billingToggle(),
          const SizedBox(height: 28),
          _membershipCard(),
          const SizedBox(height: 26),
          _couponToggle(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: showCoupon ? _couponInput() : const SizedBox(),
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Floating Rive Mascot
  // ------------------------------------------------------------
  Widget _floatingMascot() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, child) {
        final dy = _floatAnim.value;
        final tilt = math.sin(_floatController.value * 2 * math.pi) * 0.02;
        final scale = 1 + math.cos(_floatController.value * 2 * math.pi) * 0.02;

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
    );
  }

  // ------------------------------------------------------------
  // Heading text
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
  // Monthly/Yearly toggle
  // ------------------------------------------------------------
  Widget _billingToggle() {
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
  // Membership card (Glassmorphism + Glowing Border)
  // ------------------------------------------------------------
  Widget _membershipCard() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (_, __) {
        final glow = _glowAnim.value;

        return Stack(
          children: [
            // Glowing shadow
            Container(
              height: null,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.2 + glow * 0.3),
                    blurRadius: 40 + glow * 20,
                    spreadRadius: 2 + glow * 4,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
            ),

            // Glass card
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: Colors.white.withOpacity(0.09),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 1.2,
                    ),
                    gradient: fg.LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: _membershipCardContent(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Membership card content (with overflow fix)
  // ------------------------------------------------------------
  Widget _membershipCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _premiumIcon(),
            const SizedBox(width: 12),

            // <<< FIX: Title wrapped in Expanded to avoid horizontal overflow >>>
            Expanded(
              child: Text(
                "Premium Membership",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 12),

            _discountBadge(),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          isYearly ? "₹3499 / year" : "₹399 / month",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 18),

        _benefit("Flat 15% OFF on all orders"),
        _benefit("Free delivery on every order"),
        _benefit("Early access to new drops"),
        _benefit("Exclusive member-only discounts"),
        _benefit("Faster customer support"),

        const SizedBox(height: 18),

        _joinNowButton(),
      ],
    );
  }

  Widget _premiumIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: fg.LinearGradient(
          colors: [Colors.pinkAccent.shade100, const Color(0xFFB97BFF)],
        ),
      ),
      child: const Icon(Icons.workspace_premium_rounded, color: Colors.white),
    );
  }

  Widget _discountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.08),
      ),
      child: const Text(
        "15% OFF",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ------------------------------------------------------------
  // Benefit row
  // ------------------------------------------------------------
  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Join button
  // ------------------------------------------------------------
  Widget _joinNowButton() {
    return GestureDetector(
      onTap: _showJoinSheet,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: fg.LinearGradient(
            colors: [Colors.pinkAccent, const Color(0xFFB97BFF)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isMember ? "You're Already a Member" : "Join Membership",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Bottom sheet
  // ------------------------------------------------------------
  void _showJoinSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 45, height: 5, decoration: _dragHandleDecoration()),
              const SizedBox(height: 20),
              const Text(
                "Activate Premium Membership",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                isYearly ? "₹3499 / year" : "₹399 / month",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.pink.shade600),
              ),
              const SizedBox(height: 14),
              const Text(
                "Unlock exclusive perks, extra savings and free delivery.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 26),
              _joinNowBottomButton(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _dragHandleDecoration() {
    return BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(30),
    );
  }

  Widget _joinNowBottomButton() {
    return GestureDetector(
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
                fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Coupon UI
  // ------------------------------------------------------------
  Widget _couponToggle() {
    return GestureDetector(
      onTap: () => setState(() => showCoupon = !showCoupon),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer, color: Colors.pink.shade600),
          const SizedBox(width: 6),
          Text(
            showCoupon ? "Hide Coupon" : "Have a coupon?",
            style: TextStyle(
                color: Colors.pink.shade600, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _couponInput() {
    return Container(
      key: const ValueKey("coupon"),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _couponController,
              decoration: const InputDecoration(
                  hintText: "Enter coupon code", border: InputBorder.none),
            ),
          ),
          GestureDetector(
            onTap: () {
              final code = _couponController.text.trim();
              if (code.isEmpty) {
                _showMessage("Enter a coupon code");
                return;
              }

              if (code.toUpperCase() == "WELCOME15") {
                _showMessage("Coupon Applied: 15% OFF");
              } else {
                _showMessage("Invalid coupon code");
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("Apply",
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ------------------------------------------------------------
  // Confetti overlay
  // ------------------------------------------------------------
  Widget _confettiWidget() {
    return ConfettiWidget(
      confettiController: _confetti,
      blastDirectionality: BlastDirectionality.explosive,
      numberOfParticles: 30,
      emissionFrequency: 0.02,
      gravity: 0.4,
      maxBlastForce: 18,
      minBlastForce: 6,
    );
  }

  // ------------------------------------------------------------
  // Background blur orbs
  // ------------------------------------------------------------
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
          child: _blurCircle(130, Colors.amberAccent.withOpacity(0.07)),
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
