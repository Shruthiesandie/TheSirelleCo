import 'package:flutter/material.dart';

class PinterestArcMenu extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onMaleTap;
  final VoidCallback onFemaleTap;

  const PinterestArcMenu({
    super.key,
    required this.isOpen,
    required this.onMaleTap,
    required this.onFemaleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: 240,
          height: isOpen ? 150 : 60, // morph shape
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(isOpen ? 40 : 30),
              bottom: const Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(0.12),
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // MALE + FEMALE Buttons
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                left: isOpen ? 45 : 110,
                top: isOpen ? 20 : 15,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isOpen ? 1 : 0,
                  child: _genderButton(Icons.male, Colors.blue, onMaleTap),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                right: isOpen ? 45 : 110,
                top: isOpen ? 20 : 15,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isOpen ? 1 : 0,
                  child: _genderButton(Icons.female, Colors.pink, onFemaleTap),
                ),
              ),

              // CENTER BUTTON = ⚥
              Positioned(
                bottom: 5,
                child: GestureDetector(
                  onTap: () {}, // bottom nav toggles _menuOpen
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pinkAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Text(
                      "⚥",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
