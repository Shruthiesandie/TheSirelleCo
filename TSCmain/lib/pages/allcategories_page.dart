import 'package:flutter/material.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Logo
                  Image.asset(
                    "assets/logo/logo.png",
                    height: 75,
                    width: 75,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(width: 40), // keeps logo centered
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Text(
                  "Categories Page",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}