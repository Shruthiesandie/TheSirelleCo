// membership_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage>
    with TickerProviderStateMixin {
  // Mock data
  final DateTime purchaseDate =
      DateTime.now().subtract(const Duration(days: 190)); // 6+ months ago

  final double totalSavings = 124.50; // Now in ₹

  late AnimationController bgAnimController;
  late ConfettiController confettiController;

  bool hasBadge = false;

  @override
  void initState() {
    super.initState();

    // Background animation
    bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Confetti
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _loadBadge();
  }

  @override
  void dispose() {
    bgAnimController.dispose();
    confettiController.dispose();
    super.dispose();
  }

  // Load badge from storage
  Future<void> _loadBadge() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasBadge = prefs.getBool("membership_badge") ?? false;
    });
  }

  // Save badge to storage
  Future<void> _saveBadge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("membership_badge", true);
    setState(() => hasBadge = true);
  }

  // ------------------ Helpers ------------------

  int get daysSincePurchase =>
      DateTime.now().difference(purchaseDate).inDays;

  int get monthsSinceJoin => (daysSincePurchase / 30).floor();

  int get membershipYearDays => 365;

  double get membershipProgressPct =>
      ((daysSincePurchase % membershipYearDays) / membershipYearDays)
          .clamp(0.0, 1.0);

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

  // ------------------ BUILD UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // -------- PREMIUM ANIMATED BACKGROUND --------
          AnimatedBuilder(
            animation: bgAnimController,
            builder: (_, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(
                          const Color(0xFFFFF3F8),
                          const Color(0xFFFFE6F2),
                          bgAnimController.value)!,
                      Color.lerp(
                          const Color(0xFFFBE7F3),
                          const Color(0xFFFFF0F6),
                          1 - bgAnimController.value)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirection: -3.14 / 2,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),

                  const SizedBox(height: 20),

                  _membershipStatus(),

                  const SizedBox(height: 20),

                  _activePlan(),

                  const SizedBox(height: 20),

                  _stamps(),

                  const SizedBox(height: 20),

                  _cta(),

                  const SizedBox(height: 50),
                ],
              ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Membership Dashboard",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(hasBadge ? "🏅 Badge Unlocked!" : "No Badge Yet",
                style: TextStyle(
                    color: hasBadge ? Colors.green : Colors.black45)),
          ],
        ),
      ],
    );
  }

  // ---------------- SECTION 1: Membership Status ----------------
  Widget _membershipStatus() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Membership Status",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),

          _labelValue("Purchase Date", formattedDate(purchaseDate)),
          const SizedBox(height: 10),
          _labelValue("Duration", "$monthsSinceJoin month(s) completed"),
          const SizedBox(height: 20),

          // -------- Total Savings (₹) with Breathing Piggy Bank --------
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(14),
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

                // 💗 Breathing Piggy Animation
                ScaleTransition(
                  scale: Tween(begin: 0.95, end: 1.05).animate(
                    CurvedAnimation(
                      parent: bgAnimController,
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

          const SizedBox(height: 20),

          // Progress Bar
          const Text("Year Progress",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LinearProgressIndicator(
              value: membershipProgressPct,
              minHeight: 12,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
              backgroundColor: Colors.grey.shade300,
            ),
          )
        ],
      ),
    );
  }

  // ---------------- SECTION 2: Active Plan ----------------
  Widget _activePlan() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Active Plan",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
                child: const Icon(Icons.workspace_premium,
                    color: Colors.white),
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
          )
        ],
      ),
    );
  }

  // ---------------- SECTION 3: Stamps ----------------
  Widget _stamps() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Achievement Stamps",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var s in stamps) _stampTile(s),
            ],
          )
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
            SnackBar(content: Text(earned ? def.description : "Locked")));
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

  // ---------------- SECTION 4: CTA (Dynamic) ----------------
  Widget _cta() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMember ? "Ready to Renew?" : "Become a Member",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            isMember
                ? "Tap below to renew your membership."
                : "Join now to unlock all premium benefits.",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              confettiController.play();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(isMember
                          ? "Renewal Started!"
                          : "Membership Activated!")));
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
          )
        ],
      ),
    );
  }

  // ---------------- Helper Widgets ----------------

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
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
