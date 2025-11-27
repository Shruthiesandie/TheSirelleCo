import 'package:flutter/material.dart';

class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: const Center(
        child: Text(
          "Membership Page",
          style: TextStyle(fontSize: 26, color: Colors.black),
        ),
      ),
    );
  }
}
