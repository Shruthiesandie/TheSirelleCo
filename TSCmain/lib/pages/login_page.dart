import 'package:flutter/material.dart';
import 'package:rive/rive.dart';       
import 'package:flutter/services.dart';    



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late RiveAnimationController idleController;
  late RiveAnimationController successController;
  late RiveAnimationController failController;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Artboard? riveArtboard;

  @override
  void initState() {
    super.initState();

    rootBundle.load("assets/animation/login_character.riv").then((data) async {
      final file = RiveFile.import(data);
      final art = file.mainArtboard;

      idleController = SimpleAnimation("idle");
      successController = SimpleAnimation("success");
      failController = SimpleAnimation("fail");

      art.addController(idleController);

      setState(() => riveArtboard = art);
    });
  }

  void runLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Fake login logic
    if (email == "test@gmail.com" && password == "123456") {
      riveArtboard!.addController(successController);
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      riveArtboard!.addController(failController);
      Future.delayed(const Duration(seconds: 1), () {
        riveArtboard!.addController(idleController);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 260,
              child: riveArtboard == null
                  ? const SizedBox()
                  : Rive(artboard: riveArtboard!),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: runLogin,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {},
              child: const Text(
                "Create an Account",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
