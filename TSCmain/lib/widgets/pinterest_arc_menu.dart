import 'dart:ui';
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
  late AnimationController controller;

  late Animation<double> arcScale;
  late Animation<double> opacity;
  late Animation<double> maleAnim;
  late Animation<double> femaleAnim;
  late Animation<double> unisexAnim;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    arcScale = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutExpo,
    );

    opacity = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.15, 1, curve: Curves.easeOut),
    );

    maleAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.25, 1, curve: Curves.elasticOut),
    );

    femaleAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.35, 1, curve: Curves.elasticOut),
    );

    unisexAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.45, 1, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant PinterestArcMenu old) {
    super.didUpdateWidget(old);
    widget.isOpen ? controller.forward() : controller.reverse();
  }

  double clamp(double v) => v.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return Opacity(
            opacity: clamp(opacity.value),
            child: Transform.scale(
              scale: arcScale.value,
              child: _glassArc(),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🔮 GLASS ARC
  // ---------------------------------------------------------------------------
  Widget _glassArc() {
    return Center(
      child: Container(
        width: 260,
        height: 145,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(70),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.55),
              Colors.white.withOpacity(0.18),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.45),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.20),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 6,
              spreadRadius: -2,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(70),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _softGlow(),

                _menuButton(
                  -70,
                  maleAnim,
                  Icons.male,
                  [Color(0xFF6EC6FF), Color(0xFF0277BD)],
                  widget.onMaleTap,
                ),

                _menuButton(
                  0,
                  femaleAnim,
                  Icons.female,
                  [Color(0xFFFF8ECF), Color(0xFFD81B60)],
                  widget.onFemaleTap,
                ),

                _menuButton(
                  70,
                  unisexAnim,
                  Icons.transgender,
                  [Color(0xFFD1A2FF), Color(0xFF8E24AA)],
                  widget.onUnisexTap,
                ),

                _lightSweep(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ✨ Ambient Glow
  // ---------------------------------------------------------------------------
  Widget _softGlow() {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Opacity(
        opacity: clamp(opacity.value * 0.7),
        child: Container(
          width: 260,
          height: 145,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.pinkAccent.withOpacity(0.18),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 💫 Light Sweep (shimmer)
  // ---------------------------------------------------------------------------
  Widget _lightSweep() {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        double pos = arcScale.value;
        return Positioned(
          left: 260 * pos - 260,
          child: Container(
            width: 80,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0),
                  Colors.white.withOpacity(0.22 * clamp(opacity.value)),
                  Colors.white.withOpacity(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 🟣 Premium Animated Menu Button
  // ---------------------------------------------------------------------------
  Widget _menuButton(double x, Animation<double> anim, IconData icon,
      List<Color> colors, VoidCallback onTap) {
    return Transform.translate(
      offset: Offset(x, (1 - anim.value) * 55),
      child: Opacity(
        opacity: clamp(anim.value),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: clamp(anim.value),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.last.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
