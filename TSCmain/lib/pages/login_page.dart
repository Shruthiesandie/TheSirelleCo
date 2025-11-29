import 'dart:async';   // ✅ FIXED (needed for Timer)
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

  // Animations
  SimpleAnimation? idleLookAround;
  SimpleAnimation? idle;
  SimpleAnimation? lookLeft;
  SimpleAnimation? lookRight;
  SimpleAnimation? eyeCover;
  SimpleAnimation? successAnim;
  SimpleAnimation? failAnim;

  // Store animation names manually (Rive 0.12.x doesn't expose them)
  final String idleLookAroundName = "idle_look_around";
  final String idleName = "idle";
  final String leftName = "look_left";
  final String rightName = "look_right";
  final String eyeCoverName = "eye_cover";
  final String successName = "success";
  final String failName = "fail";

  final _email = TextEditingController();
  final _password = TextEditingController();

  late String _testUser;
  late String _testPass;

  Timer? idleTimer;
  bool inPassword = false;

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

  // ----------------------------------------------------
  // LOAD RIVE + FIRST ANIMATION
  void _loadRive() async {
    final data = await rootBundle.load("assets/animation/login_character.riv");
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    // Create animation controllers
    idleLookAround = SimpleAnimation(idleLookAroundName, autoplay: false);
    idle = SimpleAnimation(idleName, autoplay: false);
    lookLeft = SimpleAnimation(leftName, autoplay: false);
    lookRight = SimpleAnimation(rightName, autoplay: false);
    eyeCover = SimpleAnimation(eyeCoverName, autoplay: false);
    successAnim = SimpleAnimation(successName, autoplay: false);
    failAnim = SimpleAnimation(failName, autoplay: false);

    // Play idle look around first
    artboard.addController(idleLookAround!);
    idleLookAround!.isActive = true;

    setState(() => _artboard = artboard);

    // After 2 sec → switch to idle
    Future.delayed(const Duration(seconds: 2), () {
      _play(idleName);
    });
  }

  // ----------------------------------------------------
  // FORCE PLAY ANIMATION (BY NAME)
  void _play(String animName) {
    if (_artboard == null) return;

    SimpleAnimation newAnim = SimpleAnimation(animName, autoplay: false);

    // Restart existing animation (clean start)
    _artboard!.addController(newAnim);
    newAnim.isActive = true;

    // Assign back to correct variable
    if (animName == idleLookAroundName) idleLookAround = newAnim;
    if (animName == idleName) idle = newAnim;
    if (animName == leftName) lookLeft = newAnim;
    if (animName == rightName) lookRight = newAnim;
    if (animName == eyeCoverName) eyeCover = newAnim;
    if (animName == successName) successAnim = newAnim;
    if (animName == failName) failAnim = newAnim;
  }

  // ----------------------------------------------------
  // LOGIN LOGIC
  void _attemptLogin() {
    inPassword = false;

    if (_email.text.trim() == _testUser &&
        _password.text.trim() == _testPass) {
      _play(successName);

      Future.delayed(const Duration(milliseconds: 900), () {
        Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      _play(failName);

      Future.delayed(const Duration(seconds: 2), () {
        _play(idleName);
      });
    }
  }

  // ----------------------------------------------------
  void _restartIdleTimer() {
    idleTimer?.cancel();
    idleTimer = Timer(const Duration(seconds: 4), () {
      if (!inPassword) {
        _play(idleLookAroundName);
      }
    });
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

                  // TEST BOX
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
                                ClipboardData(text: "$_testUser:$_testPass"),
                              );
                            },
                            child: const Text("Copy"),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // USERNAME
                  TextField(
                    controller: _email,
                    onTap: () {
                      inPassword = false;
                      _play(idleName);
                      _restartIdleTimer();
                    },
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        if (val.length % 2 == 0) {
                          _play(leftName);
                        } else {
                          _play(rightName);
                        }
                      }
                      _restartIdleTimer();
                    },
                    decoration: _box("Username"),
                  ),

                  const SizedBox(height: 14),

                  // PASSWORD
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onTap: () {
                      inPassword = true;
                      _play(eyeCoverName);
                    },
                    onChanged: (_) {
                      inPassword = true;
                      _play(eyeCoverName);
                    },
                    decoration: _box("Password"),
                  ),

                  const SizedBox(height: 20),

                  // LOGIN BUTTON
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
                  : Rive(artboard: _artboard!, fit: BoxFit.contain),
            ),
          )
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
