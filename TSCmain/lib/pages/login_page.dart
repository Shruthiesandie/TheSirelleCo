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
  StateMachineController? _controller;

  // Rive Inputs
  SMIBool? _isFocus;
  SMIBool? _isPassword;
  SMITrigger? _successTrigger;
  SMITrigger? _failTrigger;
  SMINumber? _eyeTrack;

  final _email = TextEditingController();
  final _password = TextEditingController();

  late String _testUser;
  late String _testPass;

  @override
  void initState() {
    super.initState();
    _generateCredentials();
    _loadRive();
  }

  void _generateCredentials() {
    final r = Random();
    _testUser = "user${r.nextInt(900) + 100}";
    _testPass = (r.nextInt(9000) + 1000).toString();
  }

  Future<void> _loadRive() async {
    try {
      final data = await rootBundle.load("assets/animation/login_character.riv");
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;

      _controller = StateMachineController.fromArtboard(
        artboard,
        "State Machine 1",
      );

      if (_controller == null) {
        debugPrint("❌ STATE MACHINE NOT FOUND");
        return;
      }

      artboard.addController(_controller!);

      // collect inputs
      _isFocus = _controller!.findInput("isFocus") as SMIBool?;
      _isPassword = _controller!.findInput("IsPassword") as SMIBool?;
      _successTrigger = _controller!.findInput("login_success") as SMITrigger?;
      _failTrigger = _controller!.findInput("login_fail") as SMITrigger?;
      _eyeTrack = _controller!.findInput("eye_track") as SMINumber?;

      setState(() => _riveArtboard = artboard);
    } catch (e) {
      debugPrint("Rive Load Error: $e");
    }
  }

  void _attemptLogin() {
    final u = _email.text.trim();
    final p = _password.text.trim();

    if (u == _testUser && p == _testPass) {
      _successTrigger?.fire();
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      _failTrigger?.fire();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect username or password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // logo
            Image.asset("assets/logo/logo.png", height: 55),

            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Test credentials
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 22, color: Colors.pinkAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "username: $_testUser  password: $_testPass",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: "$_testUser:$_testPass"));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Copied!")),
                                );
                              },
                              child: const Text("Copy"),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Username
                    TextField(
                      controller: _email,
                      onTap: () {
                        _isFocus?.value = true;
                        _isPassword?.value = false;
                      },
                      onChanged: (v) {
                        _eyeTrack?.value = v.length.toDouble();
                      },
                      decoration: InputDecoration(
                        hintText: "Username",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Password
                    TextField(
                      controller: _password,
                      obscureText: true,
                      onTap: () {
                        _isFocus?.value = false;
                        _isPassword?.value = true;
                      },
                      onChanged: (_) {
                        _isPassword?.value = true;
                      },
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _attemptLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Create an account",
                          style: TextStyle(color: Colors.black87)),
                    ),
                  ],
                ),
              ),
            ),

            // ---------------- RIVE AT BOTTOM ----------------
            SizedBox(
              height: 200,
              child: _riveArtboard == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.pinkAccent,
                      ),
                    )
                  : Rive(
                      artboard: _riveArtboard!,
                      fit: BoxFit.contain,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
