// membership_page.dart
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

  @override
  void initState() {
    super.initState();

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    _stampsPageController = PageController(viewportFraction: 0.36);

    // load saved badge and simulate initial shimmer
    _loadBadge();
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

  Future<void> _saveBadge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("membership_badge", true);
    setState(() => hasBadge = true);
  }

  // ---------------- Helpers ----------------
  int get daysSincePurchase => DateTime.now().difference(purchaseDate).inDays;
  int get monthsSinceJoin => (daysSincePurchase / 30).floor();
  int get membershipYearDays => 365;
  double get membershipProgressPct =>
      ((daysSincePurchase % membershipYearDays) / membershipYearDays).clamp(0.0, 1.0);
  String formattedDate(DateTime d) => DateFormat.yMMMMd().format(d);
  bool get isMember => membershipActive && monthsSinceJoin >= 1;

  final List<_StampDefinition> _stamps = const [
    _StampDefinition(1, "1 Month", "Completed 1 Month"),
    _StampDefinition(3, "3 Months", "3 Month Loyalty"),
    _StampDefinition(6, "6 Months", "Half-Year Milestone"),
    _StampDefinition(12, "1 Year", "1 Year Achievement"),
    _StampDefinition(24, "2 Years", "2 Year Veteran"),
    _StampDefinition(60, "5 Years", "5 Year Legend Badge"),
  ];

  bool stampEarned(int months) => monthsSinceJoin >= months;

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
                      Color.lerp(const Color(0xFFFFF3F8), const Color(0xFFFFE6F2),
                          _bgAnimController.value)!,
                      Color.lerp(const Color(0xFFFBE7F3), const Color(0xFFFFF0F6),
                          1 - _bgAnimController.value)!,
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
                  gradient:
                      LinearGradient(colors: [Colors.pink.shade100, Colors.purple.shade100]),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      // back button
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.black87),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // logo and title
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.pink, Colors.purple]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.workspace_premium, color: Colors.white),
                      ),

                      const SizedBox(width: 12),

                      // title text (Flexible to avoid overflow)
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Membership Dashboard",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              hasBadge ? "🏅 Badge Unlocked!" : "No Badge Yet",
                              style: TextStyle(color: hasBadge ? Colors.green : Colors.black45),
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
                              .showSnackBar(const SnackBar(content: Text("Profile tapped")));
                        },
                        icon: const Icon(Icons.person_outline),
                      ),
                    ],
                  ),
                ),

                // content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          _membershipStatusCard(),
                          const SizedBox(height: 18),
                          _activePlanCard(),
                          const SizedBox(height: 18),
                          _stampsSection(),
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
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(height: 18, width: 180, color: Colors.white),
                  const SizedBox(height: 12),
                  Expanded(child: Container(color: Colors.white70)),
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
    // Use ClipRRect + BackdropFilter to support older Flutter versions (3.38.3).
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Membership Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        _labelValue("Purchase Date", formattedDate(purchaseDate)),
        _labelValue("Membership Duration", "$monthsSinceJoin month(s) completed"),

        const SizedBox(height: 12),

        // Total savings with breathing piggy
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.pink.shade50.withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Total Savings", style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Text("₹${totalSavings.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.pink, fontSize: 20, fontWeight: FontWeight.w800)),
              ]),
              const Spacer(),
              ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.06).animate(CurvedAnimation(parent: _bgAnimController, curve: Curves.easeInOut)),
                child: const Icon(Icons.savings_rounded, color: Colors.pink, size: 36),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Row(children: [
          const Text("Year Progress", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text("$percentText%", style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
          ),
        ),
      ]),
    );
  }

  // ---------------- Section 2 ----------------
  Widget _activePlanCard() {
    return _glassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Active Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        Row(children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 5))],
            ),
            child: const Center(child: Icon(Icons.workspace_premium, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text("Premium Annual Access", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("₹300 / Year", style: TextStyle(color: Colors.black54)),
          ]),
        ]),

        const SizedBox(height: 12),

        Wrap(spacing: 8, runSpacing: 8, children: const [
          _benefit(Icons.local_offer, "10% instant discount"),
          _benefit(Icons.headset_mic, "Priority support"),
          _benefit(Icons.flash_on, "Early access to sales"),
        ]),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
            child: Row(children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text("₹300 billed yearly — verified", style: TextStyle(fontSize: 13)),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        if (isMember)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _showCancelDialog,
              child: const Text("Cancel Membership", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ),
      ]),
    );
  }

  // ---------------- Section 3: Stamps (PageView snapping) ----------------
  Widget _stampsSection() {
    return _glassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Achievement Stamps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _stampsPageController,
            itemCount: _stamps.length,
            padEnds: false,
            physics: const PageScrollPhysics(),
            itemBuilder: (context, index) {
              final s = _stamps[index];
              final earned = stampEarned(s.monthsRequired);

              if (earned && s.monthsRequired == 60) _saveBadge();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(earned ? s.description : "Locked — ${s.monthsRequired} months required")));
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: earned ? Colors.pink.shade50 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: earned ? Colors.pink : Colors.grey.shade300),
                          boxShadow: [
                            if (earned)
                              BoxShadow(color: Colors.pink.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 5))
                          ],
                        ),
                        child: Icon(earned ? Icons.star : Icons.lock_outline, color: earned ? Colors.pink : Colors.grey, size: 34),
                      ),
                      const SizedBox(height: 8),
                      Text(s.title, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // simple indicator
        Center(child: PageViewIndicator(controller: _stampsPageController, itemCount: _stamps.length)),
      ]),
    );
  }

  // ---------------- CTA + Cancel flow ----------------
  Widget _ctaSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _glassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isMember ? "Ready to Renew?" : "Become a Member", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(isMember ? "Tap below to renew your membership." : "Join now to unlock all premium benefits.", style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              _confettiController.play();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isMember ? "Renewal Started!" : "Membership Activated!")));
              if (!isMember) setState(() => membershipActive = true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(isMember ? "Renew Membership" : "Join Membership", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      // If not a member show buy option; if member show manage section already via active plan card
      if (!isMember)
        _glassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Membership canceled", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text("You can re-join anytime and keep your stamps/benefits (if eligible).", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() => membershipActive = true);
                _confettiController.play();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Welcome back! Membership reactivated")));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text("Buy Membership", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
    ]);
  }

  // ---------------- Cancel confirmation dialog ----------------
  void _showCancelDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Are you sure you want to cancel?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("If you cancel you'll lose:"),
              const SizedBox(height: 8),
              Row(children: const [Icon(Icons.check, color: Colors.pink), SizedBox(width: 8), Expanded(child: Text("Instant 10% discount on orders"))]),
              const SizedBox(height: 6),
              Row(children: const [Icon(Icons.check, color: Colors.pink), SizedBox(width: 8), Expanded(child: Text("Priority customer support"))]),
              const SizedBox(height: 6),
              Row(children: const [Icon(Icons.check, color: Colors.pink), SizedBox(width: 8), Expanded(child: Text("Early access to sales"))]),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Keep Membership")),
            ElevatedButton(
              onPressed: () {
                setState(() => membershipActive = false);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Membership canceled. You can re-join anytime.")));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ]),
    );
  }
}

// ---------------- PageView Indicator ----------------
class PageViewIndicator extends StatefulWidget {
  final PageController controller;
  final int itemCount;
  const PageViewIndicator({required this.controller, required this.itemCount, super.key});

  @override
  State<PageViewIndicator> createState() => _PageViewIndicatorState();
}

class _PageViewIndicatorState extends State<PageViewIndicator> {
  double current = 0.0;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  void _listener() {
    setState(() {
      current = (widget.controller.page ?? widget.controller.initialPage).toDouble();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(widget.itemCount, (i) {
      final selected = (current - i).abs() < 0.5;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: selected ? 14 : 8,
        height: 8,
        decoration: BoxDecoration(color: selected ? Colors.pink : Colors.grey.shade300, borderRadius: BorderRadius.circular(6)),
      );
    }));
  }
}

// ---------------- Stamp definition ----------------
class _StampDefinition {
  final int monthsRequired;
  final String title;
  final String description;
  const _StampDefinition(this.monthsRequired, this.title, this.description);
}

// ---------------- Benefit chip ----------------
class _benefit extends StatelessWidget {
  final IconData icon;
  final String text;
  const _benefit(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.pink),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
