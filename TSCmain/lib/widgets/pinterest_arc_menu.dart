// pinterest_arc_menu.dart
//
// New Rainbow Soft-Gradient Minimal Menu
// Completely redesigned to match the aesthetic / pastel vibe of your app.
// This REPLACES the old arc menu (same filename, same API).
//
// Usage remains the same inside HomePage:
// PinterestArcMenu(
//   isOpen: _arcOpen,
//   onMaleTap: ...,
//   onFemaleTap: ...,
//   onUnisexTap: ...,
// )

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
  late AnimationController _ctl;

  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _maleAnim;
  late Animation<double> _femaleAnim;
  late Animation<double> _unisexAnim;
  late Animation<double> _sweepAnim;

  double maleScale = 1.0;
  double femaleScale = 1.0;
  double unisexScale = 1.0;

  @override
  void initState() {
    super.initState();

    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _scale = CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    );

    _maleAnim = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    );
    _femaleAnim = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    );
    _unisexAnim = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    );

    _sweepAnim = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant PinterestArcMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.isOpen ? _ctl.forward() : _ctl.reverse();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  LinearGradient _btnColor(int i) {
    switch (i) {
      case 0:
        return const LinearGradient(
          colors: [Color(0xFF8ED1FF), Color(0xFF63BDF0)],
        );
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFFF9ECF), Color(0xFFDE6BAF)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFD9B8FF), Color(0xFF9B7BFF)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (_, __) {
          final scale = _scale.value;
          final opacity = _opacity.value;
          final sweep = _sweepAnim.value;

          const double radius = 75;

          Offset malePos = Offset(-radius * 0.85, -radius * 0.40);
          Offset femalePos = Offset(0, -radius * 0.85);
          Offset unisexPos = Offset(radius * 0.85, -radius * 0.40);

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: 0.95 + 0.05 * scale,
              child: Center(
                child: SizedBox(
                  width: 240,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _glassMenuBackground(sweep, opacity),

                      _bubble(
                        offset: Offset.lerp(Offset.zero, malePos, _maleAnim.value)!,
                        icon: Icons.male,
                        label: "Male",
                        gradient: _btnColor(0),
                        scale: maleScale,
                        onDown: () => setState(() => maleScale = 0.92),
                        onUp: () {
                          setState(() => maleScale = 1.0);
                          widget.onMaleTap();
                        },
                      ),

                      _bubble(
                        offset: Offset.lerp(Offset.zero, femalePos, _femaleAnim.value)!,
                        icon: Icons.female,
                        label: "Female",
                        gradient: _btnColor(1),
                        scale: femaleScale,
                        onDown: () => setState(() => femaleScale = 0.92),
                        onUp: () {
                          setState(() => femaleScale = 1.0);
                          widget.onFemaleTap();
                        },
                      ),

                      _bubble(
                        offset: Offset.lerp(Offset.zero, unisexPos, _unisexAnim.value)!,
                        icon: Icons.transgender,
                        label: "Unisex",
                        gradient: _btnColor(2),
                        scale: unisexScale,
                        onDown: () => setState(() => unisexScale = 0.92),
                        onUp: () {
                          setState(() => unisexScale = 1.0);
                          widget.onUnisexTap();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  //  Glass Background with Soft Gradient Sweep
  // ----------------------------------------------------------
  Widget _glassMenuBackground(double sweep, double opacity) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        width: 180,
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.white.withOpacity(0.85),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.14),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.12 * opacity,
                  child: Transform.translate(
                    offset: Offset(sweep * 80, 0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF9ECF),
                            Color(0xFFB97BFF),
                            Color(0xFF8ED1FF),
                          ],
                          stops: [0, 0.5, 1],
                        ),
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

  // ----------------------------------------------------------
  //  Single Bubble Button
  // ----------------------------------------------------------
  Widget _bubble({
    required Offset offset,
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required double scale,
    required VoidCallback onDown,
    required VoidCallback onUp,
  }) {
    return Transform.translate(
      offset: offset,
      child: GestureDetector(
        onTapDown: (_) => onDown(),
        onTapUp: (_) => onUp(),
        onTapCancel: onUp,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // bubble
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.last.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87.withOpacity(0.85),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
