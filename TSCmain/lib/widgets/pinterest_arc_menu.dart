import 'package:flutter/material.dart';

class PinterestArcMenu extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onMaleTap;
  final VoidCallback onFemaleTap;
  final VoidCallback onUnisexTap;

  const PinterestArcMenu({
    super.key,
    required this.isOpen,
    required this.onMaleTap,
    required this.onFemaleTap,
    required this.onUnisexTap,
  });

  @override
  State<PinterestArcMenu> createState() => _PinterestArcMenuState();
}

class _PinterestArcMenuState extends State<PinterestArcMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> arcScale;
  late Animation<double> maleSlide;
  late Animation<double> femaleSlide;
  late Animation<double> unisexSlide;
  late Animation<double> fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Background arc animation
    arcScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    );

    // Slightly staggered icon slide
    maleSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 1, curve: Curves.easeOutBack)),
    );
    femaleSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 1, curve: Curves.easeOutBack)),
    );
    unisexSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.4, 1, curve: Curves.easeOutBack)),
    );

    fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1),
    );
  }

  @override
  void didUpdateWidget(covariant PinterestArcMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.isOpen ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: fadeIn.value,
            child: Transform.scale(
              scale: arcScale.value,
              child: _buildArcMenu(),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // GLASS ARC MENU (Upgraded)
  // ------------------------------------------------------------
  Widget _buildArcMenu() {
    return Center(
      child: Container(
        width: 260,
        height: 140,
        decoration: BoxDecoration(
          // Glassmorphism
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(70),
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.10),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              blurRadius: 6,
              offset: const Offset(-2, -2),
            ),
          ],
        ),

        child: Stack(
          alignment: Alignment.center,
          children: [
            // Floating highlight behind icons
            _floatingGlow(-70, Colors.blueAccent),
            _floatingGlow(0, Colors.pinkAccent),
            _floatingGlow(70, Colors.purpleAccent),

            // Male
            Transform.translate(
              offset: Offset(-70, maleSlide.value),
              child: _circleButton(
                Icons.male,
                const LinearGradient(
                  colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                ),
                widget.onMaleTap,
              ),
            ),

            // Female
            Transform.translate(
              offset: Offset(0, femaleSlide.value),
              child: _circleButton(
                Icons.female,
                const LinearGradient(
                  colors: [Color(0xFFFF80AB), Color(0xFFE91E63)],
                ),
                widget.onFemaleTap,
              ),
            ),

            // Unisex
            Transform.translate(
              offset: Offset(70, unisexSlide.value),
              child: _circleButton(
                Icons.transgender,
                const LinearGradient(
                  colors: [Color(0xFFCE93D8), Color(0xFF8E24AA)],
                ),
                widget.onUnisexTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ICON BUTTON WITH GLOW + GRADIENT (Upgraded)
  // ------------------------------------------------------------
  Widget _circleButton(
      IconData icon, Gradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: widget.isOpen ? 1 : 0.001,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutBack,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: Icon(icon, size: 30, color: Colors.white),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FLOATING GLOW BEHIND EACH ICON
  // ------------------------------------------------------------
  Widget _floatingGlow(double xOffset, Color color) {
    return Positioned(
      left: 130 + xOffset,
      top: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Opacity(
            opacity: fadeIn.value * 0.5,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.20),
              ),
            ),
          );
        },
      ),
    );
  }
}
