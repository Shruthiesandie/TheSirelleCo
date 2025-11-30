// username_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  // Default blocked usernames
  final List<String> defaultTaken = ["vishruth", "shruthi"];

  // Saved usernames (persistent)
  List<String> savedUsernames = [];

  // Status values:
  // "empty", "checking", "available", "taken", "invalid"
  String status = "empty";
  String invalidReason = ""; // when status == invalid
  bool loading = false;

  // Hover / press state for UI
  bool _cardHover = false;
  bool _buttonHover = false;
  bool _buttonPressed = false;

  // Animation controllers
  late AnimationController successCtrl;
  late Animation<double> successScale;
  late Animation<double> glowPulse;

  @override
  void initState() {
    super.initState();
    loadSavedUsernames();

    successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    successScale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: successCtrl, curve: Curves.easeOutBack),
    );

    glowPulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
          parent: successCtrl,
          curve: const Interval(0.0, 1.0, curve: Curves.easeOut)),
    );
  }

  Future<void> loadSavedUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    savedUsernames = prefs.getStringList("usernames") ?? [];
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    successCtrl.dispose();
    super.dispose();
  }

  // ---------------- Validation rules ----------------
  // Allowed: letters, numbers, underscore. No spaces.
  final RegExp _validRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  bool _meetsBasicRules(String value) {
    if (value.contains(' ')) {
      invalidReason = "No spaces allowed";
      return false;
    }
    if (!_validRegex.hasMatch(value)) {
      invalidReason = "Only letters, numbers and underscore allowed";
      return false;
    }
    if (value.length < 3) {
      invalidReason = "Username must be at least 3 characters";
      return false;
    }
    return true;
  }

  // ---------------- Check username (with simulated delay) ----------------
  Timer? _debounce;
  void checkUsername(String raw) {
    final value = raw.trim();

    // Cancel previous debounce
    _debounce?.cancel();

    if (value.isEmpty) {
      setState(() {
        status = "empty";
        invalidReason = "";
      });
      return;
    }

    // Validate basic rules immediately
    if (!_meetsBasicRules(value)) {
      setState(() {
        status = "invalid";
      });
      return;
    }

    // Basic rules passed → show checking
    setState(() {
      status = "checking";
    });

    // Debounce to avoid frequent checks
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      final username = value.toLowerCase();

      // simulate a network/DB check delay
      await Future.delayed(const Duration(milliseconds: 400));

      final exists = defaultTaken.contains(username) ||
          savedUsernames.contains(username);

      setState(() {
        status = exists ? "taken" : "available";
      });

      if (!exists) {
        // small success pulse
        successCtrl.forward().then((_) => successCtrl.reverse());
      }
    });
  }

  // Helper text for status
  String getStatusText() {
    switch (status) {
      case "checking":
        return "Checking availability…";
      case "available":
        return "Username available ✓";
      case "taken":
        return "Already exists ✗";
      case "invalid":
        return invalidReason;
      default:
        return "";
    }
  }

  Color getStatusColor() {
    switch (status) {
      case "checking":
        return Colors.blue.shade600;
      case "available":
        return Colors.green.shade600;
      case "taken":
        return Colors.red.shade600;
      case "invalid":
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade400;
    }
  }

  // ---------------- Save username and navigate ----------------
  Future<void> _acceptAndContinue() async {
    if (status != "available") return;

    final prefs = await SharedPreferences.getInstance();
    final name = _controller.text.trim().toLowerCase();

    // protect duplicates (race)
    if (defaultTaken.contains(name) || savedUsernames.contains(name)) {
      setState(() => status = "taken");
      return;
    }

    savedUsernames = [...savedUsernames, name];
    await prefs.setStringList("usernames", savedUsernames);

    // success pulse + short delay then navigate
    await successCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 180));
    await successCtrl.reverse();

    if (!mounted) return;
    Navigator.pushNamed(context, "/home");
  }

  // ---------------- UI BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardElevation = _cardHover ? 18.0 : 8.0;
    final cardTranslate = _cardHover ? -8.0 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Pick your username",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.pink.shade700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "This is how others will find you. Use letters, numbers or underscore.",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 28),

                // Floating glass card with hover lift
                MouseRegion(
                  onEnter: (_) => setState(() => _cardHover = true),
                  onExit: (_) => setState(() => _cardHover = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    transform: Matrix4.translationValues(0, cardTranslate, 0),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.86),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: cardElevation,
                          offset: Offset(0, cardElevation / 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input field row with prefix and availability border glow
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            // Glow border when available
                            border: Border.all(
                              color: status == "available"
                                  ? Colors.green.shade400
                                  : Colors.grey.shade200,
                              width: status == "available" ? 2.2 : 1.0,
                            ),
                            boxShadow: status == "available"
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.green.shade200.withOpacity(0.18),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              // left badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.alternate_email,
                                    color: Colors.pink.shade400),
                              ),

                              // actual input
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  onChanged: checkUsername,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    hintText: "your_username",
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 8),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),

                              // status dot + small label
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    // animated dot
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 260),
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (status == "checking")
                                            ? Colors.blue.shade500
                                            : (status == "available")
                                                ? Colors.green.shade500
                                                : (status == "taken")
                                                    ? Colors.red.shade500
                                                    : (status == "invalid")
                                                        ? Colors.orange.shade700
                                                        : Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // status text row
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                getStatusText(),
                                style: TextStyle(
                                  color: getStatusColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // show a small check on available with scale animation
                            ScaleTransition(
                              scale: successScale,
                              child: Opacity(
                                opacity: status == "available" ? 1.0 : 0.0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // helper / rules row
                        Wrap(
                          spacing: 10,
                          children: [
                            _ruleChip("Min 3 chars",
                                active: _controller.text.trim().length >= 3),
                            _ruleChip("Letters, numbers, _",
                                active: _validRegex
                                    .hasMatch(_controller.text.trim()) ||
                                    _controller.text.isEmpty),
                            _ruleChip("No spaces",
                                active: !_controller.text.contains(' ')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Continue row: button + small secondary action
                Row(
                  children: [
                    // Main continue button with gradient + neon glow
                    Expanded(
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _buttonHover = true),
                        onExit: (_) => setState(() {
                          _buttonHover = false;
                          _buttonPressed = false;
                        }),
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _buttonPressed = true),
                          onTapUp: (_) => setState(() => _buttonPressed = false),
                          onTapCancel: () => setState(() => _buttonPressed = false),
                          onTap: status == "available" ? _acceptAndContinue : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 56,
                            transform: Matrix4.identity()
                              ..translate(0.0, _buttonHover ? -6.0 : 0.0)
                              ..scale(_buttonPressed ? 0.98 : 1.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6FAF), Color(0xFFB97BFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: status == "available"
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.shade300.withOpacity(0.22),
                                        blurRadius: 22,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 10),
                                      ),
                                      // soft neon glow
                                      BoxShadow(
                                        color: Colors.pink.shade300.withOpacity(0.06),
                                        blurRadius: 40,
                                        spreadRadius: 4,
                                      )
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                                      )
                                    ],
                            ),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                  letterSpacing: 0.6,
                                ),
                                child: Text(status == "available" ? "Continue" : "Continue"),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Cancel / Back small button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back, size: 18, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text("Back", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 18),

                // Small note / existing usernames preview
                Opacity(
                  opacity: 0.9,
                  child: Text(
                    "Taken examples: vishruth, shruthi${savedUsernames.isEmpty ? '' : ', ' + savedUsernames.join(', ')}",
                    style: TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // small rule chip
  Widget _ruleChip(String label, {required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? Colors.green.shade200 : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(active ? Icons.check : Icons.close, size: 14, color: active ? Colors.green.shade600 : Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.green.shade700 : Colors.black54, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
