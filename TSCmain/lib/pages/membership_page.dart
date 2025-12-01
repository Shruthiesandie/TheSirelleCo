// membership_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // add intl to pubspec.yaml if not present

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> with TickerProviderStateMixin {
  // ---------- Mock / Sample User Membership Data ----------
  // Change purchaseDate to test different stamp states (older -> more stamps earned)
  final DateTime purchaseDate = DateTime.now().subtract(const Duration(days: 190)); // ~6+ months
  final double annualCost = 300.0;
  final double membershipDiscountPct = 10.0; // 10% discount on purchases
  final double totalSavings = 124.50; // sample total savings value

  // ---------- UI / controllers ----------
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ---------- Helper computed values ----------
  int get daysSincePurchase => DateTime.now().difference(purchaseDate).inDays;

  int get membershipYearDays {
    // assume membership year = 365 days (no leap handling necessary for UI)
    return 365;
  }

  int get daysRemaining {
    final days = membershipYearDays - (daysSincePurchase % membershipYearDays);
    return days <= 0 ? 0 : days;
  }

  double get membershipProgressPct {
    final passed = daysSincePurchase % membershipYearDays;
    return (passed / membershipYearDays).clamp(0.0, 1.0);
  }

  String get membershipDurationLabel {
    final months = (daysSincePurchase / 30).floor();
    if (daysSincePurchase < 30) return "$daysSincePurchase days remaining since join";
    if (months < 12) return "Member for $months month${months > 1 ? 's' : ''}";
    final years = (months / 12).floor();
    return "Member for $years year${years > 1 ? 's' : ''}";
  }

  // ---------- Stamps Definitions ----------
  final List<_StampDefinition> _stamps = [
    _StampDefinition(monthsRequired: 1, title: "1 Month", description: "Completed 1 month of membership"),
    _StampDefinition(monthsRequired: 3, title: "3 Months", description: "Loyal for 3 months"),
    _StampDefinition(monthsRequired: 6, title: "6 Months", description: "Half-year supporter"),
    _StampDefinition(monthsRequired: 12, title: "1 Year", description: "1 year membership milestone"),
    _StampDefinition(monthsRequired: 24, title: "2 Years", description: "Two-year veteran"),
    _StampDefinition(monthsRequired: 60, title: "5 Years", description: "5 years of loyalty"),
  ];

  bool stampEarned(_StampDefinition def) {
    final months = (daysSincePurchase / 30).floor();
    return months >= def.monthsRequired;
  }

  String formattedDate(DateTime d) => DateFormat.yMMMMd().format(d);

  // ---------- UI Build ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Transparent app bar to let background show; still comfortable for a single page
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Soft two-tone gradient background with subtle vignette via overlay
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFFFF5F8), const Color(0xFFFCECF1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  // Page header
                  Row(
                    children: [
                      _buildLogoAndTitle(),
                      const Spacer(),
                      _buildProfileQuickInfo(),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Four rectangular sections stacked vertically (desktop focus)
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 900;

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Section 1: Membership status card
                            _membershipStatusCard(theme, isNarrow),
                            const SizedBox(height: 18),

                            // Section 2: Active Plan Details
                            _activePlanCard(theme, isNarrow),
                            const SizedBox(height: 18),

                            // Section 3: Loyalty & achievement stamps
                            _stampsSection(theme, isNarrow),
                            const SizedBox(height: 18),

                            // Section 4: CTA
                            _ctaSection(theme),
                            const SizedBox(height: 30),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Header: logo + page title ----------
  Widget _buildLogoAndTitle() {
    return Row(
      children: [
        // simple round logo placeholder
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: const Center(child: Icon(Icons.card_membership, color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text("Membership", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 2),
          Text("Dashboard", style: TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
      ],
    );
  }

  // ---------- top-right: small profile action (keeps minimal) ----------
  Widget _buildProfileQuickInfo() {
    return Row(
      children: [
        // small saved badge
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.bookmark_border),
          tooltip: "Saved membership badge",
        ),
        const SizedBox(width: 6),
        // mock profile avatar
        CircleAvatar(radius: 18, backgroundColor: Colors.pink.shade100, child: const Icon(Icons.person, color: Colors.white)),
      ],
    );
  }

  // ---------- Section 1: Membership Status Card ----------
  Widget _membershipStatusCard(ThemeData theme, bool isNarrow) {
    final progressPct = membershipProgressPct;
    final percentText = (progressPct * 100).toStringAsFixed(0);

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            children: [
              const Icon(Icons.insights, color: Colors.pink, size: 22),
              const SizedBox(width: 10),
              const Text("Membership Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              // subtle action
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.help_outline, size: 18),
                label: const Text("What's this?", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // main content grid
          Flex(
            direction: isNarrow ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // left column: purchase date & duration
              Expanded(
                flex: 3,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _labelValue("Purchase Date", formattedDate(purchaseDate)),
                  const SizedBox(height: 10),
                  _labelValue("Membership Duration", membershipDurationLabel),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text("$daysRemaining days remaining", style: const TextStyle(color: Colors.black87)),
                  ]),
                ]),
              ),

              const SizedBox(width: 18, height: 18),

              // right column: savings + progress
              Expanded(
                flex: 2,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // total savings card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFF0F5), Color(0xFFFFF7FB)]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink.shade50),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text("Total Savings", style: TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 6),
                        Text("\$${totalSavings.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.pink)),
                      ]),
                      ScaleTransition(
                        scale: Tween(begin: 0.98, end: 1.02).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)),
                        child: const Icon(Icons.savings, color: Colors.pink),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 12),

                  // progress bar with percentage label
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text("Year Progress", style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(width: 8),
                      Text("$percentText%", style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressPct,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("${(progressPct * membershipYearDays).floor()} of $membershipYearDays days elapsed", style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ])
                ]),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ---------- small helper for label+value ----------
  Widget _labelValue(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    ]);
  }

  // ---------- Section 2: Active Plan Details ----------
  Widget _activePlanCard(ThemeData theme, bool isNarrow) {
    return _cardContainer(
      child: Flex(
        direction: isNarrow ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left: icon + plan name
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: const Center(child: Icon(Icons.workspace_premium, color: Colors.white, size: 30)),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text("Premium Annual Access", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text("\$300 / Year", style: TextStyle(fontSize: 13, color: Colors.black54)),
                ]),
              ],
            ),
          ),

          // right: benefits list + verify cost box
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _benefitChip(Icons.local_offer, "10% Discount on all purchases"),
                    _benefitChip(Icons.headset_mic, "Priority Customer Support"),
                    _benefitChip(Icons.flash_on, "Exclusive Early Access to Sales"),
                  ],
                ),
                const SizedBox(height: 14),
                // cost verification box
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 10),
                            const Expanded(child: Text("\$300 billed yearly — verified")),
                            TextButton(
                              onPressed: () {},
                              child: const Text("View receipt"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.pink),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---------- Section 3: Loyalty & Achievement Stamps ----------
  Widget _stampsSection(ThemeData theme, bool isNarrow) {
    // horizontal scroll on small screens, grid on wide screens
    final isGrid = !isNarrow;
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.emoji_events, color: Colors.pink), SizedBox(width: 10), Text("Loyalty Stamps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 12),
          if (isGrid)
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _stamps.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1),
              itemBuilder: (_, i) => _stampTile(i),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) => _stampTile(i),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: _stamps.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _stampTile(int index) {
    final def = _stamps[index];
    final earned = stampEarned(def);

    final stampContent = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      height: 84,
      width: 84,
      decoration: BoxDecoration(
        color: earned ? Colors.pink.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (earned) BoxShadow(color: Colors.pink.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: earned ? Colors.pink.shade100 : Colors.grey.shade200, width: 1.5),
      ),
      child: Center(
        child: Icon(
          earned ? Icons.star : Icons.lock_outline,
          color: earned ? Colors.pink : Colors.grey.shade400,
          size: 34,
        ),
      ),
    );

    // tooltip message for earned stamps; unearned show hint when tapped
    final tooltip = earned ? def.description : "Keep engaging — unlock at ${def.monthsRequired} months";

    // Hover/scale effect
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // On tap, show small SnackBar for mobile where hover isn't available
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(earned ? 'Unlocked: ${def.title} — ${def.description}' : 'Locked — ${tooltip}')));
        },
        child: Tooltip(
          message: tooltip,
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: stampContent,
          ),
        ),
      ),
    );
  }

  // ---------- Section 4: CTA ----------
  Widget _ctaSection(ThemeData theme) {
    return _cardContainer(
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Ready to continue your membership?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text("Renew now to keep enjoying member discounts and exclusive access.", style: TextStyle(color: Colors.black54)),
            ]),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // stub: implement real action (payment flow / renew)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Renewal flow started")));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6FAF),
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 8,
              shadowColor: Colors.pink.withOpacity(0.28),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            child: const Text("Renew Membership"),
          ),
        ],
      ),
    );
  }

  // ---------- Generic card container used for sections ----------
  Widget _cardContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 6))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: child,
    );
  }
}

// ---------- Simple stamp def ----------
class _StampDefinition {
  final int monthsRequired;
  final String title;
  final String description;
  const _StampDefinition({required this.monthsRequired, required this.title, required this.description});
}
