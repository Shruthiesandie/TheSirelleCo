// membership_dashboard_page.dart
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
  final DateTime purchaseDate =
      DateTime.now().subtract(const Duration(days: 190));

  final double totalSavings = 124.50;

  late AnimationController bgAnimController;
  late ConfettiController confettiController;

  bool hasBadge = false;
  bool isLoading = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _loadBadge();
    _enableShimmerLoader();

    _scrollController.addListener(() {
      // Snap every 350px (Apple-like)
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.idle) return;

      Future.delayed(const Duration(milliseconds: 160), () {
        final offset = _scrollController.offset;
        final snap = (offset / 350).round() * 350;
        _scrollController.animateTo(
          snap.toDouble(),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  Future<void> _enableShimmerLoader() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    bgAnimController.dispose();
    confettiController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  int get daysSincePurchase =>
      DateTime.now().difference(purchaseDate).inDays;

  int get monthsSinceJoin => (daysSincePurchase / 30).floor();

  double get membershipProgressPct =>
      ((daysSincePurchase % 365) / 365).clamp(0.0, 1.0);

  bool get isMember => monthsSinceJoin >= 1;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: bgAnimController,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFFFFF3F8),
                          const Color(0xFFFFE6F2), bgAnimController.value)!,
                      Color.lerp(const Color(0xFFFBE7F3),
                          const Color(0xFFFFF0F6), 1 - bgAnimController.value)!,
                    ],
                  ),
                ),
              );
            },
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirection: -3.14 / 2,
              numberOfParticles: 20,
              emissionFrequency: 0.05,
            ),
          ),

          SafeArea(
            child: ListView(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _header(),

                const SizedBox(height: 20),

                isLoading ? _shimmerCard() : _membershipStatus(),

                const SizedBox(height: 20),

                isLoading ? _shimmerCard() : _activePlan(),

                const SizedBox(height: 20),

                isLoading ? _shimmerCard() : _stamps(),

                const SizedBox(height: 20),

                isLoading ? _shimmerCard() : _cta(),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 22),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [Colors.pink, Colors.purple]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.workspace_premium, color: Colors.white),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Membership Dashboard",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      hasBadge ? "🏅 Badge Unlocked!" : "No Badge Yet",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasBadge ? Colors.green : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- SHIMMER ----------------
  Widget _shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.white,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  // ---------------- SECTION 1 ----------------
  Widget _membershipStatus() {
    return _glassCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Membership Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),

          _labelValue("Purchase Date", formattedDate(purchaseDate)),
          _labelValue("Duration", "$monthsSinceJoin month(s) completed"),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.pink.shade50.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              backdropFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Savings",
                        style: TextStyle(color: Colors.black54)),
                    Text("₹${totalSavings.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.pink,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                ScaleTransition(
                  scale: Tween(begin: 0.95, end: 1.05).animate(
                    CurvedAnimation(
                      parent: bgAnimController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: const Icon(Icons.savings_rounded,
                      color: Colors.pink, size: 38),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text("Year Progress",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LinearProgressIndicator(
              value: membershipProgressPct,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SECTION 2 ----------------
  Widget _activePlan() {
    return _glassCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Active Plan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [Colors.pink, Colors.purple]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    const Icon(Icons.workspace_premium, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Premium Annual Access",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("₹300 / Year",
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _benefit(Icons.local_offer, "10% instant discount"),
              _benefit(Icons.headset_mic, "Priority support"),
              _benefit(Icons.flash_on, "Early access to sales"),
            ],
          ),

          const SizedBox(height: 20),

          if (isMember)
            _cancelMembershipButton(),
        ],
      ),
    );
  }

  Widget _cancelMembershipButton() {
    return TextButton(
      onPressed: _showCancelPopup,
      child: const Text(
        "Cancel Membership",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCancelPopup() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Wait! You're losing benefits"),
          content: const Text(
              "By cancelling your membership, you will lose:\n\n• 10% instant discount\n• Priority support\n• Early access to sales\n\nAre you sure?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Keep Membership", style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("Membership Cancelled")));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Cancel Anyway"),
            ),
          ],
        );
      },
    );
  }

  // ---------------- SECTION 3 ----------------
  Widget _stamps() {
    return _glassCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Achievement Stamps",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var s in stamps) _stampTile(s),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stampTile(_StampDefinition def) {
    final earned = stampEarned(def.monthsRequired);

    if (earned && def.monthsRequired == 60) _saveBadge();

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                earned ? def.description : "Locked — Earn at ${def.monthsRequired} months"),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: earned ? Colors.pink.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: earned ? Colors.pink : Colors.grey.shade300),
          boxShadow: [
            if (earned)
              BoxShadow(
                  color: Colors.pink.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(
          earned ? Icons.star : Icons.lock_outline,
          color: earned ? Colors.pink : Colors.grey,
          size: 34,
        ),
      ),
    );
  }

  // ---------------- SECTION 4: CTA ----------------
  Widget _cta() {
    return _glassCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMember ? "Ready to Renew?" : "Become a Member",
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          Text(
            isMember
                ? "Tap below to renew your membership."
                : "Join now to unlock all premium benefits.",
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 18),

          ElevatedButton(
            onPressed: () {
              confettiController.play();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(isMember ? "Renewal Started!" : "Membership Activated!"),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              backgroundColor: Colors.pink,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isMember ? "Renew Membership" : "Join Membership",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Helpers ----------------

  Widget _labelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
    );
  }

  Widget _glassCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
        backdropFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      ),
      child: child,
    );
  }
}

// ---------------- Stamp Definition ----------------
class _StampDefinition {
  final int monthsRequired;
  final String title;
  final String description;

  const _StampDefinition(
      this.monthsRequired, this.title, this.description);
}

// ---------------- Benefit Chip ----------------
class _benefit extends StatelessWidget {
  final IconData icon;
  final String text;

  const _benefit(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.pink),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
