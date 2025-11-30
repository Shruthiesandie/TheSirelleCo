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

  // Allowed characters regex
  final RegExp _validRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  // Preblocked usernames
  final List<String> defaultTaken = ["vishruth", "shruthi"];

  List<String> savedUsernames = [];

  // status = empty, checking, taken, available
  String status = "empty";

  bool loading = false;

  // Success animation
  late AnimationController successCtrl;
  late Animation<double> successScale;

  // Button hover + press animations
  double btnScale = 1.0;
  double cardLift = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedUsernames();

    successCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

    successScale = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(parent: successCtrl, curve: Curves.easeOutBack),
    );
  }

  Future<void> _loadSavedUsernames() async {
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

  // ---------------------------------------------------------------------------
  // CHECK USERNAME
  // ---------------------------------------------------------------------------
  void checkUsername(String value) {
    value = value.trim();

    if (value.isEmpty) {
      setState(() => status = "empty");
      return;
    }

    // BASIC VALIDATIONS FIRST
    if (value.contains(" ")) {
      setState(() => status = "space");
      return;
    }

    if (!_validRegex.hasMatch(value)) {
      setState(() => status = "invalid");
      return;
    }

    if (value.length < 3) {
      setState(() => status = "short");
      return;
    }

    // FAKE LOADING
    setState(() {
      loading = true;
      status = "checking";
    });

    Future.delayed(const Duration(milliseconds: 900), () async {
      final username = value.toLowerCase();

      bool exists =
          defaultTaken.contains(username) || savedUsernames.contains(username);

      setState(() {
        loading = false;
        status = exists ? "taken" : "available";
      });

      if (!exists) {
        successCtrl.forward().then((_) => successCtrl.reverse());
      }
    });
  }

  // ---------------------------------------------------------------------------
  // COLORS & TEXT HELPERS
  // ---------------------------------------------------------------------------
  Color getBorderColor() {
    switch (status) {
      case "checking":
        return Colors.blueAccent;
      case "available":
        return Colors.greenAccent.shade400;
      case "taken":
        return Colors.redAccent;
      case "short":
      case "invalid":
      case "space":
        return Colors.orange;
      default:
        return Colors.transparent;
    }
  }

  String getStatusText() {
    switch (status) {
      case "checking":
        return "Checking availability…";
      case "available":
        return "Username available ✓";
      case "taken":
        return "Already exists ✗";
      case "invalid":
        return "Only letters, numbers, underscore allowed";
      case "space":
        return "No spaces allowed";
      case "short":
        return "Must be at least 3 characters";
      default:
        return "";
    }
  }

  Color getDotColor() {
    switch (status) {
      case "checking":
        return Colors.blueAccent;
      case "available":
        return Colors.green;
      case "taken":
      case "invalid":
      case "space":
      case "short":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ---------------------------------------------------------------------------
  // RULE CHIPS
  // ---------------------------------------------------------------------------
  Widget _ruleChip(String text, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: active ? Colors.green.withOpacity(0.15) : Colors.white,
        border: Border.all(
          color: active ? Colors.green : Colors.black26,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: active ? Colors.green.shade800 : Colors.black54,
          fontSize: 12,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),

      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title -------------------------------
            Text(
              "Choose a username",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.pink.shade700,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              "This will be your identity in the app.",
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 35),

            // Floating Glass Card ------------------------------------
            MouseRegion(
              onEnter: (_) => setState(() => cardLift = -4),
              onExit: (_) => setState(() => cardLift = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.translationValues(0, cardLift, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: getBorderColor(),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.12),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // TextField -----------------------------
                    TextField(
                      controller: _controller,
                      onChanged: checkUsername,
                      decoration: InputDecoration(
                        hintText: "Enter username",
                        prefixIcon: Icon(Icons.person,
                            color: Colors.pink.shade300),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Status Row ----------------------------
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: getDotColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          getStatusText(),
                          style: TextStyle(
                            color: status == "available"
                                ? Colors.green.shade800
                                : Colors.red.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Requirement Chips ----------------------
                    Wrap(
                      spacing: 10,
                      children: [
                        _ruleChip(
                          "Min 3 chars",
                          _controller.text.isNotEmpty &&
                              _controller.text.trim().length >= 3,
                        ),
                        _ruleChip(
                          "Letters, numbers, _",
                          _controller.text.isNotEmpty &&
                              _validRegex.hasMatch(_controller.text.trim()),
                        ),
                        _ruleChip(
                          "No spaces",
                          _controller.text.isNotEmpty &&
                              !_controller.text.contains(" "),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Continue Button ---------------------------------------
            Listener(
              onPointerDown: (_) => setState(() => btnScale = 0.95),
              onPointerUp: (_) => setState(() => btnScale = 1.0),
              child: GestureDetector(
                onTap: status == "available"
                    ? () async {
                        final prefs = await SharedPreferences.getInstance();

                        // Save username
                        savedUsernames.add(_controller.text.toLowerCase());
                        prefs.setStringList("usernames", savedUsernames);

                        Navigator.pushNamed(context, "/home");
                      }
                    : null,
                child: AnimatedScale(
                  scale: btnScale,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: status == "available" ? 1 : 0.4,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF6FAF),
                            Color(0xFFB97BFF),
                          ],
                        ),
                      ),
                      child: Center(
                        child: ScaleTransition(
                          scale: successScale,
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
