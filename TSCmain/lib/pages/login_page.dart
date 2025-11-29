import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Artboard? _riveArtboard;
  late SimpleAnimation _idleAnim;
  late SimpleAnimation _successAnim;
  late SimpleAnimation _failAnim;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // generated test credentials
  late String _testUsername;
  late String _testPassword;

  @override
  void initState() {
    super.initState();
    _generateTestCredentials();
    _loadRive();
  }

  void _generateTestCredentials() {
    final rnd = Random();
    final u = "user${rnd.nextInt(900) + 100}";
    final p = "${rnd.nextInt(9000) + 1000}";
    _testUsername = u;
    _testPassword = p;

    // prefill the fields with empty to force user entry; optionally prefill for quick test:
    // _emailController.text = _testUsername;
    // _passwordController.text = _testPassword;
  }

  Future<void> _loadRive() async {
    try {
      final data = await rootBundle.load('assets/animations/login_character.riv');
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;

      // Animation names inside the Rive file must match these names:
      // "idle", "success", "fail"
      // If your file uses different names, change them below.
      _idleAnim = SimpleAnimation('idle');
      _successAnim = SimpleAnimation('success');
      _failAnim = SimpleAnimation('fail');

      artboard.addController(_idleAnim);
      setState(() => _riveArtboard = artboard);
    } catch (e) {
      // If Rive fails to load, log error and continue (UI will still be usable)
      debugPrint("Rive load error: $e");
    }
  }

  void _playSuccessThenGoHome() {
    if (_riveArtboard == null) return;
    // remove idle and play success
    _riveArtboard!.removeController(_idleAnim);
    _riveArtboard!.addController(_successAnim);

    // after animation, go to home
    Future.delayed(const Duration(milliseconds: 900), () {
      // restore idle for next time
      _riveArtboard!..removeController(_successAnim);
      _riveArtboard!..addController(_idleAnim);

      // Navigate to home
      Navigator.pushReplacementNamed(context, "/home");
    });
  }

  void _playFailThenIdle() {
    if (_riveArtboard == null) return;
    _riveArtboard!.removeController(_idleAnim);
    _riveArtboard!.addController(_failAnim);

    Future.delayed(const Duration(milliseconds: 900), () {
      _riveArtboard!..removeController(_failAnim);
      _riveArtboard!..addController(_idleAnim);
    });
  }

  void _attemptLogin() {
    final inputUser = _emailController.text.trim();
    final inputPass = _passwordController.text.trim();

    if (inputUser == _testUsername && inputPass == _testPassword) {
      _playSuccessThenGoHome();
    } else {
      _playFailThenIdle();
      // Optionally show snack bar message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect credentials")),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _riveWidget() {
    if (_riveArtboard == null) {
      // placeholder while rive loads
      return SizedBox(
        height: 220,
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(80),
              boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 10)],
            ),
            child: const Icon(Icons.person, size: 64, color: Colors.pinkAccent),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: Rive(
        artboard: _riveArtboard!,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Logo at top (keeps your existing logo)
              Image.asset('assets/logo/logo.png', height: 60),
              const SizedBox(height: 8),

              // Rive area
              _riveWidget(),
              const SizedBox(height: 12),

              // Show test credentials for quick demo (remove in production)
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.pinkAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Test credentials — username: $_testUsername  password: $_testPassword",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // copy for convenience
                          Clipboard.setData(ClipboardData(text: '$_testUsername:$_testPassword'));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied credentials')));
                        },
                        child: const Text("Copy"),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Email input
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Username",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 12),

              // Password input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 18),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _attemptLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // optional: navigate to signup or show note
                },
                child: const Text("Create an account", style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
