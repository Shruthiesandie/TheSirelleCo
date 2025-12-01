// membership_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage>
    with TickerProviderStateMixin {
  // Mock Data
  final DateTime purchaseDate =
      DateTime.now().subtract(const Duration(days: 190));

  final double totalSavings = 124.50;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Helpers
  int get daysSincePurchase =>
      DateTime.now().difference(purchaseDate).inDays;

  int get membershipYearDays => 365;

  int get daysRemaining =>
      membershipYearDays - (daysSincePurchase % membershipYearDays);

  double get membershipProgressPct =>
      ((daysSincePurchase % membershipYearDays) / membershipYearDays)
          .clamp(0.0, 1.0);

  String formattedDate(DateTime d) => DateFormat.yMMMMd().format(d);

  int get monthsSinceJoin => (daysSincePurchase / 30).floor();

  final List<_StampDefinition> _stamps = const [
    _StampDefinition(
        monthsRequired: 1,
        title: "1 Month",
        description: "Completed your first month"),
    _StampDefinition(
        monthsRequired: 3,
        title: "3 Months",
        description: "3 months loyalty"),
    _StampDefinition(
        monthsRequired: 6,
        title: "6 Months",
        description: "Half-year milestone"),
    _StampDefinition(
        monthsRequired: 12,
        title: "1 Year",
        description: "1 Year Achievement"),
    _StampDefinition(
        monthsRequired: 24,
        title: "2 Years",
        description: "2 Year Veteran"),
    _StampDefinition(
        monthsRequired: 60,
        title: "5 Years",
        description: "5 Year Legend"),
  ];

  bool stampEarned(_StampDefinition def) =>
      monthsSinceJoin >= def.monthsRequired;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BEAUTIFUL SOFT GRADIENT BACKGROUND
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF5F8), Color(0xFFFCECF1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        // FULL PAGE SCROLL — OPTION A
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),

                const SizedBox(height: 20),

                // SECTION 1
                _membershipStatusCard(),

                const SizedBox(height: 20),

                // SECTION 2
                _activePlanDetailsCard(),

                const SizedBox(height: 20),

                // SECTION 3
                _loyaltyStampsSection(),

                const SizedBox(height: 20),

                // SECTION 4
                _renewCTA(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- HEADER -----------------
  Widget _header() {
    return Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.card_membership, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Membership", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Dashboard", style: TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  // ----------------- SECTION 1 -----------------
  Widget _membershipStatusCard() {
    final pct = membershipProgressPct;
    final percentText = (pct * 100).toStringAsFixed(0);

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Membership Status",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),

          // Purchase Info
          _labelValue("Purchase Date", formattedDate(purchaseDate)),
          const SizedBox(height: 10),

          _labelValue(
              "Membership Duration", "$monthsSinceJoin month(s)"),
          const SizedBox(height: 16),

          // TOTAL SAVINGS
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Savings",
                        style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text("\$${totalSavings.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.pink,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const Spacer(),
                ScaleTransition(
                  scale: Tween(begin: 0.95, end: 1.05).animate(
                      CurvedAnimation(
                          parent: _pulseController,
                          curve: Curves.easeInOut)),
                  child: const Icon(Icons.savings,
                      color: Colors.pink, size: 30),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // PROGRESS BAR
          Text("Year Progress $percentText%",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 12,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 8),
          Text("${(pct * membershipYearDays).floor()} of $membershipYearDays days elapsed",
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  // ----------------- SECTION 2 -----------------
  Widget _activePlanDetailsCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Active Membership",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    const Icon(Icons.workspace_premium, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Premium Annual Access",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("₹300 / Year",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // BENEFITS
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _benefit(Icons.local_offer, "10% Discount on all purchases"),
              _benefit(Icons.headset_mic, "Priority Customer Support"),
              _benefit(Icons.flash_on, "Early Access to Sales"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.pink),
          const SizedBox(width: 6),
          Text(text,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  // ----------------- SECTION 3 -----------------
  Widget _loyaltyStampsSection() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Loyalty Stamps",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // Wrap works PERFECT for mobile, no layout bugs
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (int i = 0; i < _stamps.length; i++) _stampTile(i),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stampTile(int index) {
    final def = _stamps[index];
    final earned = stampEarned(def);

    return Tooltip(
      message: earned
          ? def.description
          : "Unlock at ${def.monthsRequired} months",
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    earned ? "Unlocked: ${def.title}" : "Locked — ${def.monthsRequired} months required")),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 82,
          width: 82,
          decoration: BoxDecoration(
            color: earned ? Colors.pink.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: earned
                    ? Colors.pink.shade200
                    : Colors.grey.shade300),
            boxShadow: [
              if (earned)
                BoxShadow(
                    color: Colors.pink.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 5)),
            ],
          ),
          child: Icon(
            earned ? Icons.star : Icons.lock_outline,
            size: 36,
            color: earned ? Colors.pink : Colors.grey,
          ),
        ),
      ),
    );
  }

  // ----------------- SECTION 4 -----------------
  Widget _renewCTA() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ready to Renew?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),

          const Text("Renew now to continue enjoying member-only perks.",
              style: TextStyle(color: Colors.black54)),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Membership renewal flow started")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6FAF),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Renew Membership",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- CARD WRAPPER -----------------
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

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _StampDefinition {
  final int monthsRequired;
  final String title;
  final String description;

  const _StampDefinition({
    required this.monthsRequired,
    required this.title,
    required this.description,
  });
}
