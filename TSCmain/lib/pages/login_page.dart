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

  late SimpleAnimation introAnim;
  late SimpleAnimation idleAnim;
  late SimpleAnimation lookLeft;
  late SimpleAnimation lookRight;
  late SimpleAnimation eyeCover;
  late SimpleAnimation successAnim;
  late SimpleAnimation failAnim;

  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _eyeClosed = false;

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

  void play(SimpleAnimation anim) {
    anim.isActive = false;
    anim.isActive = true;
    _artboard?.addController(anim);
  }

  Future<void> _loadRive() async {
    final data = await rootBundle.load("assets/animation/login_character.riv");
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    introAnim = SimpleAnimation("Intro", autoplay: false);
    idleAnim = SimpleAnimation("idle", autoplay: false);
    lookLeft = SimpleAnimation("look_left", autoplay: false);
    lookRight = SimpleAnimation("look_right", autoplay: false);
    eyeCover = SimpleAnimation("eye_cover", autoplay: false);
    successAnim = SimpleAnimation("success", autoplay: false);
    failAnim = SimpleAnimation("fail", autoplay: false);

    // Play intro once when app loads
    artboard.addController(introAnim);

    // 🔥 Since callback not supported, use timer equal to intro duration
    Future.delayed(const Duration(milliseconds: 1800), () {
      play(idleAnim);
    });

    setState(() => _artboard = artboard);
  }

  void _attemptLogin() {
    String user = _email.text.trim();
    String pass = _password.text.trim();

    play(idleAnim);

    if (user == _testUser && pass == _testPass) {
      play(successAnim);
      Future.delayed(const Duration(milliseconds: 900), () {
        Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      play(failAnim);
    }
  }

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
                              "username: $_testUser   password: $_testPass",
                            ),
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
                    onTap: () {
                      _eyeClosed = false;
                      play(idleAnim);
                    },
                    onChanged: (value) {
                      if (!_eyeClosed) {
                        if (value.length % 2 == 0) {
                          play(lookLeft);
                        } else {
                          play(lookRight);
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
                    onTap: () {
                      _eyeClosed = true;
                      play(eyeCover);
                    },
                    onChanged: (_) {
                      _eyeClosed = true;
                      play(eyeCover);
                    },
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

          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 260,
              child: _artboard == null
                  ? const Center(child: CircularProgressIndicator())
                  : Rive(artboard: _artboard!, fit: BoxFit.contain),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
