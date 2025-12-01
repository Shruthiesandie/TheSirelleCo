// membership_dashboard_page.dart
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
  // -------------------- MOCK DATA --------------------
  final DateTime purchaseDate =
      DateTime.now().subtract(const Duration(days: 190)); // 6+ months
  final double totalSavings = 124.50; // INR display

  // ------------------ CONTROLLERS / STATE ------------------
  late final AnimationController bgAnimController;
  late final ConfettiController confettiController;

  bool hasBadge = false;
  bool membershipActive = true; // toggled by "Cancel membership" flow
  bool isLoading = true; // shimmer loading

  // PageController for stamps (scroll snapping)
  late final PageController _stampsPageController;

  @override
  void initState() {
    super.initState();

    // background animation (breathing gradient)
    bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _stampsPageController = PageController(viewportFraction: 0.36);

    // load persisted badge and simulate initial shimmer loading
    _loadBadge();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => isLoading = false);
    });

    // membershipActive initial state: true if user is already a member (1+ month)
    membershipActive = monthsSinceJoin >= 1;
  }

  @override
  void dispose() {
    bgAnimController.dispose();
    confettiController.dispose();
    _stampsPageController.dispose();
    super.dispose();
  }

  // ---------------- PERSISTENCE ----------------
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

  // ---------------- HELPERS ----------------
  int get daysSincePurchase =>
      DateTime.now().difference(purchaseDate).inDays;

  int get monthsSinceJoin => (daysSincePurchase / 30).floor();

  int get membershipYearDays => 365;

  double get membershipProgressPct =>
      ((daysSincePurchase % membershipYearDays) / membershipYearDays)
          .clamp(0.0, 1.0);

  bool get isMember => monthsSinceJoin >= 1 && membershipActive;

  String formattedDate(DateTime d) => DateFormat.yMMMMd().format(d);

  final List<_StampDefinition> stamps = const [
    _StampDefinition(1, "1 Month", "Completed 1 Month"),
    _StampDefinition(3, "3 Months", "3 Month Loyalty"),
    _StampDefinition(6, "6 Months", "Half-Year Milestone"),
    _StampDefinition(12, "1 Year", "1 Year Achievement"),
    _StampDefinition(24, "2 Years", "2 Year Veteran"),
    _StampDefinition(60, "5 Years", "5 Year Legend Badge"),
  ];

  bool stampEarned(int months) => monthsSinceJoin >= months;

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // keep status bar area safe
      body: Stack(
        children: [
          // Animated premium background
          AnimatedBuilder(
            animation: bgAnimController,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFFFFF3F8), const Color(0xFFFFE6F2),
                          bgAnimController.value)!,
                      Color.lerp(const Color(0xFFFBE7F3), const Color(0xFFFFF0F6),
                          1 - bgAnimController.value)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // subtle decorative soft wave at top-right using translucent circle(s)
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
                    colors: [Colors.pink.shade100, Colors.purple.shade100],
                  ),
                ),
              ),
            ),
          ),

          // Confetti (center-top)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 24,
              shouldLoop: false,
              emissionFrequency: 0.02,
              maxBlastForce: 20,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar with back button + title (keeps logo placement intent)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () {
                          // go back to previous route if possible
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            // fallback: do nothing
                          }
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

                      // Title area (kept similar)
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Colors.pink, Colors.purple]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.workspace_premium, color: Colors.white),
                      ),

                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Membership Dashboard",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(hasBadge ? "🏅 Badge Unlocked!" : "No Badge Yet",
                              style: TextStyle(color: hasBadge ? Colors.green : Colors.black45)),
                        ],
                      ),

                      const Spacer(),

                      // profile quick icon (unchanged)
                      IconButton(
                        onPressed: () {
                          // placeholder: open profile or saved badge
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text("Profile tapped")));
                        },
                        icon: const Icon(Icons.person_outline),
                      ),
                    ],
                  ),
                ),

                // body scroll (Option A — full page scroll)
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 6),

                        // MEMBERSHIP STATUS — shimmer while loading
                        if (isLoading)
                          _shimmerCard(height: 180)
                        else
                          _membershipStatus(),

                        const SizedBox(height: 18),

                        // ACTIVE PLAN (glassmorphism card)
                        if (isLoading)
                          _shimmerCard(height: 160)
                        else
                          _activePlan(),

                        const SizedBox(height: 18),

                        // STAMPS SECTION — scroll snapping PageView on mobile look
                        if (isLoading)
                          _shimmerCard(height: 140)
                        else
                          _stamps(),

                        const SizedBox(height: 18),

                        // CTA + Cancel/Join flow
                        _ctaSection(),

                        const SizedBox(height: 30),
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

  // ------------------- SHIMMER PLACEHOLDER -------------------
  Widget _shimmerCard({required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 18, width: 180, color: Colors.white),
                const SizedBox(height: 12),
                Expanded(child: Container(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------- CARD (GLASSMORPHISM) -------------------
  Widget _glassCard({required Widget child}) {
    // Glass effect wrapper; used for each major section
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6))
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ------------------- SECTION: Membership Status -------------------
  Widget _membershipStatus() {
    final pct = membershipProgressPct;
    final percentText = (pct * 100).toStringAsFixed(0);

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Membership Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          _labelValue("Purchase Date", formattedDate(purchaseDate)),
          const SizedBox(height: 8),

          _labelValue("Duration", "$monthsSinceJoin month(s) completed"),
          const SizedBox(height: 14),

          // Total Savings with breathing piggy
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
                // breathing piggy
                ScaleTransition(
                  scale: Tween(begin: 0.96, end: 1.06).animate(
                    CurvedAnimation(parent: bgAnimController, curve: Curves.easeInOut),
                  ),
                  child: const Icon(Icons.savings_rounded, color: Colors.pink, size: 36),
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar + label
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
        ],
      ),
    );
  }

  // ------------------- SECTION: Active Plan -------------------
  Widget _activePlan() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Active Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),

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

          const SizedBox(height: 8),

          // cost verification small badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
              child: Row(children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text("₹300 billed yearly — verified", style: TextStyle(fontSize: 13)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- SECTION: Stamps (scroll snapping) -------------------
  Widget _stamps() {
    // We're using a snapping PageView to achieve Apple-like snapping.
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Achievement Stamps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: PageView.builder(
              controller: _stampsPageController,
              itemCount: stamps.length,
              padEnds: false,
              physics: const PageScrollPhysics(), // snapping physics
              itemBuilder: (context, index) {
                final s = stamps[index];
                final earned = stampEarned(s.monthsRequired);

                // when user reaches 5-year stamp, save badge
                if (earned && s.monthsRequired == 60) _saveBadge();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      // quick feedback
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text(earned ? s.description : "Locked — ${s.monthsRequired} months required")));
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
                              if (earned) BoxShadow(color: Colors.pink.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 5))
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

          const SizedBox(height: 10),
          // small page indicator to reinforce snapping UX
          SizedBox(
            height: 18,
            child: Center(
              child: PageViewIndicator(controller: _stampsPageController, itemCount: stamps.length),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- CTA + Cancel/Join flow -------------------
  Widget _ctaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _glassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isMember ? "Ready to Renew?" : "Become a Member", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(isMember ? "Tap below to renew your membership." : "Join now to unlock all premium benefits.", style: const TextStyle(color: Colors.black54)),

            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: () {
                // join or renew
                confettiController.play();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isMember ? "Renewal Started!" : "Membership Activated!")));
                // if joining, set membershipActive true (simulate purchase)
                if (!isMember) {
                  setState(() => membershipActive = true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isMember ? "Renew Membership" : "Join Membership", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),

        const SizedBox(height: 12),

        // Cancel membership button (only shown if currently active member)
        if (isMember)
          _glassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Manage Membership", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text("You can cancel membership here. We'll show what you will miss.", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _showCancelDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.12)),
                ),
                child: const Text("Cancel Membership"),
              ),
            ]),
          )
        else
          // after cancel show quick buy option card (keeps buy option visible)
          _glassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Membership canceled", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text("You can still re-join anytime and keep your stamps/benefits.", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => membershipActive = true);
                  confettiController.play();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Welcome back! Membership reactivated")));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text("Buy Membership", style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ]),
          ),
      ],
    );
  }

  // ---------------- Cancel dialog ----------------
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
                // user confirms cancellation
                setState(() => membershipActive = false);
                Navigator.of(ctx).pop();
                // show permanent buy option and message
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

  // ---------------- small helpers / UI bits ----------------
  Widget _labelValue(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    ]);
  }
}

// ---------------- PageView indicator widget (simple) ----------------
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

// ---------------- Stamp Definition ----------------
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
