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
  Artboard? _artboard;

  RiveAnimationController? idleLook;
  RiveAnimationController? lookLeft;
  RiveAnimationController? lookRight;

  // IMPORTANT — we rebuild eyeCover each time so it restarts
  RiveAnimationController? eyeCover;

  RiveAnimationController? successAnim;
  RiveAnimationController? failAnim;

  final _email = TextEditingController();
  final _password = TextEditingController();

  late String _testUser;
  late String _testPass;

  bool _isTypingPassword = false;
  bool _forceEyeCover = false; // <-- SUPER IMPORTANT

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

  void _loadRive() async {
    final data = await rootBundle.load("assets/animation/login_character.riv");
    final file = RiveFile.import(data);

    final artboard = file.mainArtboard;

    idleLook = SimpleAnimation("idle_look_around");
    lookLeft = SimpleAnimation("look_left", autoplay: false);
    lookRight = SimpleAnimation("look_right", autoplay: false);

    successAnim = SimpleAnimation("success", autoplay: false);
    failAnim = SimpleAnimation("fail", autoplay: false);

    artboard.addController(idleLook!);

    setState(() => _artboard = artboard);
  }

  // ----------------------------------------------------
  // FORCE loop eye cover by constantly retriggering
  void _loopEyeCover() {
    if (!_forceEyeCover || _artboard == null) return;

    // Remove old controller
    if (eyeCover != null) {
      _artboard!.removeController(eyeCover!);
    }

    // Recreate so it starts again
    eyeCover = SimpleAnimation("eye_cover", autoplay: true);

    _artboard!.addController(eyeCover!);

    // Call again when animation ends (~1s delay)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_forceEyeCover) _loopEyeCover();
    });
  }

  // ----------------------------------------------------
  void _startEyeCover() {
    _isTypingPassword = true;
    _forceEyeCover = true;

    idleLook?.isActive = false;

    _loopEyeCover();
  }

  void _stopEyeCover() {
    _forceEyeCover = false;
    _isTypingPassword = false;

    idleLook?.isActive = true;
  }

  // ----------------------------------------------------
  void _attemptLogin() async {
    final u = _email.text.trim();
    final p = _password.text.trim();

    _stopEyeCover();

    idleLook?.isActive = false;

    if (u == _testUser && p == _testPass) {
      _artboard!.addController(successAnim!);

      await Future.delayed(const Duration(milliseconds: 900));

      idleLook?.isActive = true;
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      _artboard!.addController(failAnim!);

      await Future.delayed(const Duration(milliseconds: 900));
      idleLook?.isActive = true;
    }
  }

  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset("assets/logo/logo.png", height: 60),
                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.pink),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                "username: $_testUser   password: $_testPass"),
                          ),
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: "$_testUser:$_testPass"));
                            },
                            child: const Text("Copy"),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // USERNAME FIELD
                  TextField(
                    controller: _email,
                    onChanged: (v) {
                      if (!_isTypingPassword) {
                        if (v.length % 2 == 0) {
                          _artboard!.addController(lookLeft!);
                        } else {
                          _artboard!.addController(lookRight!);
                        }
                      }
                    },
                    decoration: _box("Username"),
                  ),

                  const SizedBox(height: 14),

                  // PASSWORD FIELD
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onTap: _startEyeCover,
                    onChanged: (_) => _startEyeCover(),
                    onEditingComplete: _stopEyeCover,
                    decoration: _box("Password"),
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),

          // RIVE CHARACTER
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 260,
              child: _artboard == null
                  ? const Center(child: CircularProgressIndicator())
                  : Rive(
                      artboard: _artboard!,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _box(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
