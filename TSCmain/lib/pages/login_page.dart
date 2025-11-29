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

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

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

      if (_controller != null) {
        artboard.addController(_controller!);

        _isFocus = _controller!.findInput("isFocus") as SMIBool?;
        _isPassword = _controller!.findInput("IsPassword") as SMIBool?;
        _successTrigger = _controller!.findInput("login_success") as SMITrigger?;
        _failTrigger = _controller!.findInput("login_fail") as SMITrigger?;
        _eyeTrack = _controller!.findInput("eye_track") as SMINumber?;
      }

      setState(() => _riveArtboard = artboard);
    } catch (e) {
      debugPrint("Rive error: $e");
    }
  }

  // ---------------- LOGIN LOGIC ----------------
  void _attemptLogin() {
    final username = _email.text.trim();
    final password = _password.text.trim();

    if (username == _testUser && password == _testPass) {
      _successTrigger?.fire();

      Future.delayed(const Duration(milliseconds: 900), () {
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
        child: Stack(
          children: [
            // -------------------- MAIN FORM --------------------
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Your Logo
                  Image.asset("assets/logo/logo.png", height: 60),

                  const SizedBox(height: 20),

                  // Test Credentials Box
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.pinkAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "username: $_testUser   password: $_testPass",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: "$_testUser:$_testPass"));
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
                    onChanged: (value) {
                      _eyeTrack?.value = value.length.toDouble();
                    },
                    decoration: InputDecoration(
                      hintText: "Username",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Password
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onTap: () {
                      _isFocus?.value = false;
                      _isPassword?.value = true; // Eye cover
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _attemptLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Create an account"),
                  ),

                  const SizedBox(height: 200), // Make space for animation
                ],
              ),
            ),

            // -------------------- RIVE AT BOTTOM --------------------
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 260,
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
            )
          ],
        ),
      ),
    );
  }
}
