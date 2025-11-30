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
  final _controller = TextEditingController();

  // Default blocked usernames
  final List<String> defaultTaken = ["vishruth", "shruthi"];

  // Saved usernames (persistent)
  List<String> savedUsernames = [];

  String status = "empty";
  bool loading = false;

  late AnimationController successCtrl;
  late Animation<double> successScale;

  @override
  void initState() {
    super.initState();
    loadSavedUsernames();

    successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    successScale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: successCtrl, curve: Curves.easeOutBack),
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

  // ---------------------------------------------------------------------------
  // CHECK USERNAME
  // ---------------------------------------------------------------------------
  void checkUsername(String value) {
    if (value.isEmpty) {
      setState(() => status = "empty");
      return;
    }

    setState(() {
      loading = true;
      status = "checking";
    });

    Future.delayed(const Duration(milliseconds: 900), () async {
      final username = value.toLowerCase();

      bool exists = defaultTaken.contains(username) ||
          savedUsernames.contains(username);

      setState(() {
        loading = false;
        status = exists ? "taken" : "available";
      });

      if (!exists) {
        successCtrl.forward().then((_) => successCtrl.reverse());
      }
    });
  }

  // Colors for availability dot
  Color getDotColor() {
    switch (status) {
      case "checking":
        return Colors.blue;
      case "available":
        return Colors.green;
      case "taken":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Status text under input
  String getStatusText() {
    switch (status) {
      case "checking":
        return "Checking availability…";
      case "available":
        return "Username is available ✓";
      case "taken":
        return "Already exists ✗";
      default:
        return "";
    }
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

      body: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Choose a username",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.pink.shade700,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "This username will be your identity across the app.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // Glass card input
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
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

                  const SizedBox(height: 14),

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
                          color: status == "taken"
                              ? Colors.red.shade500
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Continue button
            GestureDetector(
              onTap: status == "available"
                  ? () async {
                      final prefs =
                          await SharedPreferences.getInstance();

                      // Save username permanently
                      savedUsernames.add(_controller.text.toLowerCase());
                      prefs.setStringList("usernames", savedUsernames);

                      // Navigate to home
                      Navigator.pushNamed(context, "/home");
                    }
                  : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: status == "available" ? 1.0 : 0.4,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
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
                          fontSize: 17,
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
