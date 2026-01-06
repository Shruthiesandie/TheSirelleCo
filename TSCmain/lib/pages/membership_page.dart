// membership_page.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_underscores, camel_case_types

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:shimmer/shimmer.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage>
    with TickerProviderStateMixin {
  // ---------------- MOCK DATA ----------------
  final DateTime purchaseDate =
      DateTime.now().subtract(const Duration(days: 190)); // ~6+ months ago
  final double totalSavings = 124.50; // shown in INR

  // ---------------- CONTROLLERS / STATE ----------------
  late final AnimationController _bgAnimController;
  late final ConfettiController _confettiController;
  late final PageController _stampsPageController;

  bool hasBadge = false;
  bool membershipActive = true; // toggled on cancel / join
  bool isLoading = true; // shimmer loader

  // ⭐ NEW: stamp / loyalty logic
  static const int stampsPerCycle = 6;
  int purchasesInCycle = 0; // 0–6
  bool couponAvailable = false; // shown on home page

  @override
  void initState() {
    super.initState();

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _stampsPageController = PageController(viewportFraction: 0.36);

    // load saved badge + loyalty & simulate shimmer
    _loadBadge();
    _loadLoyaltyState();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => isLoading = false);
    });

    // initial membership status
    membershipActive = monthsSinceJoin >= 1;
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _confettiController.dispose();
    _stampsPageController.dispose();
    super.dispose();
  }

  // ---------------- Persistence ----------------
  Future<void> _loadBadge() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasBadge = prefs.getBool("membership_badge") ?? false;
    });
  }

  // ⭐ NEW: load/save stamp cycle + coupon flag
  Future<void> _loadLoyaltyState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      purchasesInCycle = prefs.getInt("loyalty_purchases_cycle") ?? 0;
      couponAvailable = prefs.getBool("loyalty_coupon_available") ?? false;
    });
  }

  Future<void> _saveLoyaltyState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("loyalty_purchases_cycle", purchasesInCycle);
    await prefs.setBool("loyalty_coupon_available", couponAvailable);
  }

  /// Call this from your order flow when a purchase is completed
  Future<void> registerPurchase() async {
    if (!mounted) return;

    setState(() {
      // each purchase adds one stamp until 6
      purchasesInCycle =
          (purchasesInCycle + 1).clamp(0, stampsPerCycle);
    });

    if (purchasesInCycle >= stampsPerCycle) {
      // all 6 filled → reward ready
      _confettiController.play();
    }

    await _saveLoyaltyState();
  }

  /// Called when user taps "Claim reward & reset stamps"
  Future<void> _claimRewardAndReset() async {
    if (!mounted) return;

    setState(() {
      couponAvailable = true; // home page can now show coupon banner
      purchasesInCycle = 0; // reset cycle
    });

    await _saveLoyaltyState();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Reward claimed! A coupon will appear on your Home page 🎁",
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------
  int get daysSincePurchase =>
      DateTime.now().difference(purchaseDate).inDays;
  int get monthsSinceJoin => (daysSincePurchase / 30).floor();
  int get membershipYearDays => 365;
  double get membershipProgressPct =>
      ((daysSincePurchase % membershipYearDays) / membershipYearDays)
          .clamp(0.0, 1.0);
  String formattedDate(DateTime d) =>
      DateFormat.yMMMMd().format(d);
  bool get isMember => membershipActive && monthsSinceJoin >= 1;

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // animated background
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(
                            const Color(0xFFFFF3F8),
                            const Color(0xFFFFE6F2),
                            _bgAnimController.value,
                          ) ??
                          const Color(0xFFFFF3F8),
                      Color.lerp(
                            const Color(0xFFFBE7F3),
                            const Color(0xFFFFF0F6),
                            1 - _bgAnimController.value,
                          ) ??
                          const Color(0xFFFBE7F3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // decorative soft circle
          Positioned(
            top: -60,
            right: -40,
            child: Opacity(
              opacity: 0.12,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.shade100,
                      Colors.purple.shade100
                    ],
                  ),
                ),
              ),
            ),
          ),

          // confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 24,
              shouldLoop: false,
              emissionFrequency: 0.02,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // top header (fixed)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // back button
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // logo and title
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.pink, Colors.purple],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // title text (Flexible to avoid overflow)
                      Flexible(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Membership Dashboard",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              hasBadge
                                  ? "🏅 Badge Unlocked!"
                                  : "No Badge Yet",
                              style: TextStyle(
                                color: hasBadge
                                    ? Colors.green
                                    : Colors.black45,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text("Profile tapped"),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_outline),
                      ),
                    ],
                  ),
                ),

                // content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        if (isLoading) ...[
                          _shimmerCard(height: 180),
                          const SizedBox(height: 18),
                          _shimmerCard(height: 150),
                          const SizedBox(height: 18),
                          _shimmerCard(height: 140),
                          const SizedBox(height: 18),
                          _shimmerCard(height: 120),
                        ] else ...[
                          _loyaltyCard(),
                          const SizedBox(height: 18),
                          _membershipStatusCard(),
                          const SizedBox(height: 18),
                          _activePlanCard(),
                          const SizedBox(height: 18),
                          _stampsSection(), // ⭐ NEW GRID
                          const SizedBox(height: 18),
                          _ctaSection(),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
// ---------------- Loyalty Card ----------------
// ---------------- Loyalty Card (Pink Premium + Bigger) ----------------
// ---------------- Loyalty Card (Pink Premium + Bigger) ----------------
Widget _loyaltyCard() {
  final joinDate = formattedDate(purchaseDate);
  final expiryDate =
      formattedDate(purchaseDate.add(const Duration(days: 365)));

  return AnimatedBuilder(
    animation: _bgAnimController,
    builder: (context, child) {
      final tilt = (_bgAnimController.value - 0.5) * 0.04;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(tilt)
          ..rotateY(-tilt),
        child: child,
      );
    },
    child: Transform.scale(
      scale: 1.0,
      alignment: Alignment.topCenter,
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [
              Color(0x00FF4F9A),
              Color(0x55FF4F9A),
              Color(0x00FF4F9A),
            ],
            stops: [0.35, 0.5, 0.65],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF4F9A),
                Color(0xFFE28BFF),
                Color(0xFFF6C1FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66FF6FAF),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFFA3C7),
                              Color(0xFFFFD1E3),
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFFFFBFD),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.85, end: 1.05),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                            builder: (_, value, child) =>
                                Transform.scale(scale: value, child: child),
                            child: const Text(
                              "S",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB1005A),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        top: -6,
                        right: -6,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Sirelle Loyalty Card",
                    style: TextStyle(
                      color: Color(0xFF5A1036),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _bgAnimController,
                    builder: (_, child) {
                      final beat =
                          1 + (0.12 * Curves.easeInOut.transform(_bgAnimController.value));
                      return Opacity(
                        opacity: beat > 1.05 ? 1.0 : 0.85,
                        child: Transform.scale(
                          scale: beat,
                          child: child,
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.favorite,
                      size: 20,
                      color: Color(0xFF9E4C73),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      "5278  3940  8274  6193",
                      style: TextStyle(
                        color: Color(0xFF6A1F43),
                        fontSize: 18,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    height: 34,
                    width: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF3D6A3),
                          Color(0xFFD8B16A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.memory,
                      size: 20,
                      color: Color(0xFF6A4A1E),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Joined: $joinDate",
                        style: const TextStyle(
                          color: Color(0xFF7A3B58),
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Expires: $expiryDate",
                        style: const TextStyle(
                          color: Color(0xFF9A5E7A),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  // ---------------- Shimmer placeholder ----------------
  Widget _shimmerCard({required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    height: 18,
                    width: 180,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Glass card helper ----------------
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ---------------- Section 1 ----------------
  Widget _membershipStatusCard() {
    final pct = membershipProgressPct;
    final percentText = (pct * 100).toStringAsFixed(0);

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Membership Status",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          _labelValue("Purchase Date", formattedDate(purchaseDate)),
          _labelValue("Membership Duration",
              "$monthsSinceJoin month(s) completed"),

          const SizedBox(height: 12),

          // Total savings with breathing piggy
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.pink.shade50.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Savings",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "₹${totalSavings.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.pink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ScaleTransition(
                  scale: Tween(begin: 0.96, end: 1.06).animate(
                    CurvedAnimation(
                      parent: _bgAnimController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: const Icon(
                    Icons.savings_rounded,
                    color: Colors.pink,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Text(
                "Year Progress",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                "$percentText%",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.pink.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Section 2 ----------------
  Widget _activePlanCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Active Plan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Premium Annual Access",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "₹300 / Year",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _benefit(Icons.local_offer, "10% instant discount"),
              _benefit(Icons.headset_mic, "Priority support"),
              _benefit(Icons.flash_on, "Early access to sales"),
            ],
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "₹300 billed yearly — verified",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (isMember)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _showCancelDialog,
                child: const Text(
                  "Cancel Membership",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- Section 3: NEW 6-STAMP GRID ----------------
  Widget _stampsSection() {
    final filled = purchasesInCycle.clamp(0, stampsPerCycle);

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Purchase Stamps",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$filled of $stampsPerCycle purchases completed",
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),

          // cute explanation chip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.pink.shade50.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline,
                    size: 16, color: Colors.pink),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Each purchase fills one stamp. Collect 6 to unlock a surprise coupon ✨",
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3 x 2 stamp grid (fixed layout)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stampsPerCycle,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,          // 3 per row
              crossAxisSpacing: 16,       // horizontal spacing
              mainAxisSpacing: 16,        // vertical spacing
              childAspectRatio: 0.85,     // give a bit more height to avoid overflow
            ),
            itemBuilder: (context, index) {
              final earned = index < filled;
              final stampNumber = index + 1;
              return _buildStampBubble(stampNumber, earned);
            },
          ),

          const SizedBox(height: 16),

          if (filled >= stampsPerCycle) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.17),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.celebration,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "All 6 stamps filled! Claim your reward and we’ll drop a coupon on your Home page 🎁",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _claimRewardAndReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Claim reward & reset stamps",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else if (couponAvailable) ...[
            // optional: small note that a coupon is waiting on home
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.card_giftcard,
                    size: 18, color: Colors.pink),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "You have an unclaimed coupon waiting on your Home page 🎁",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStampBubble(int number, bool earned) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 72,
          width: 72,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), // square with rounded corners
              gradient: earned
                  ? const LinearGradient(
                      colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                    )
                  : null,
              color:
                  earned ? null : Colors.grey.shade200,
              boxShadow: [
                if (earned)
                  BoxShadow(
                    color:
                        Colors.pink.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
              ],
              border: Border.all(
                color: earned
                    ? Colors.transparent
                    : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: earned
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 26,
                    )
                  : Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Stamp $number",
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------- CTA + Cancel flow ----------------
  Widget _ctaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMember ? "Ready to Renew?" : "Become a Member",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isMember
                    ? "Tap below to renew your membership."
                    : "Join now to unlock all premium benefits.",
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _confettiController.play();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isMember
                            ? "Renewal Started!"
                            : "Membership Activated!",
                      ),
                    ),
                  );
                  if (!isMember) {
                    setState(() => membershipActive = true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isMember ? "Renew Membership" : "Join Membership",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!isMember)
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Membership canceled",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You can re-join anytime and keep your stamps/benefits (if eligible).",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() => membershipActive = true);
                    _confettiController.play();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Welcome back! Membership reactivated",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Buy Membership",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ---------------- Cancel confirmation dialog ----------------
  void _showCancelDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
              "Are you sure you want to cancel?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("If you cancel you'll lose:"),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.check, color: Colors.pink),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Instant 10% discount on orders",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(Icons.check, color: Colors.pink),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text("Priority customer support"),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(Icons.check, color: Colors.pink),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text("Early access to sales"),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Keep Membership"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => membershipActive = false);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Membership canceled. You can re-join anytime.",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text("Cancel anyway"),
            ),
          ],
        );
      },
    );
  }

  // ---------------- small helpers ----------------
  Widget _labelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- PageView Indicator (still used by old stamps? kept for compatibility) ----------------
class PageViewIndicator extends StatefulWidget {
  final PageController controller;
  final int itemCount;
  const PageViewIndicator({
    required this.controller,
    required this.itemCount,
    super.key,
  });

  @override
  State<PageViewIndicator> createState() =>
      _PageViewIndicatorState();
}

class _PageViewIndicatorState
    extends State<PageViewIndicator> {
  double current = 0.0;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  void _listener() {
    setState(() {
      current = (widget.controller.page ??
              widget.controller.initialPage)
          .toDouble();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          List.generate(widget.itemCount, (i) {
        final selected = (current - i).abs() < 0.5;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin:
              const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected
                ? Colors.pink
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}

// ---------------- Benefit chip ----------------
class _benefit extends StatelessWidget {
  final IconData icon;
  final String text;
  const _benefit(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.pink,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}