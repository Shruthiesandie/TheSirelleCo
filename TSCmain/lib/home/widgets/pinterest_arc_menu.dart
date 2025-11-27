import 'dart:ui';
import 'package:flutter/material.dart';

class PinterestArcMenu extends StatefulWidget {
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
  State<PinterestArcMenu> createState() => _PinterestArcMenuState();
}

class _PinterestArcMenuState extends State<PinterestArcMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      reverseDuration: const Duration(milliseconds: 350),
    );

    if (widget.isOpen) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant PinterestArcMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 70,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;

          return SizedBox(
            width: 260,
            height: lerpDouble(70, 170, t)!,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ------------------------------
                // ARC (hidden completely when closed)
                // ------------------------------
                if (t > 0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ArcPainter(progress: t),
                    ),
                  ),

                // ------------------------------
                // MALE BUTTON
                // ------------------------------
                Positioned(
                  top: lerpDouble(60, 20, t)!,
                  left: lerpDouble(115, 45, t)!,
                  child: Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: lerpDouble(0.5, 1.0, t)!,
                      child: _genderButton(
                          Icons.male, Colors.blue, widget.onMaleTap),
                    ),
                  ),
                ),

                // ------------------------------
                // FEMALE BUTTON
                // ------------------------------
                Positioned(
                  top: lerpDouble(60, 20, t)!,
                  right: lerpDouble(115, 45, t)!,
                  child: Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: lerpDouble(0.5, 1, t)!,
                      child: _genderButton(
                          Icons.female, Colors.pink, widget.onFemaleTap),
                    ),
                  ),
                ),

                // ------------------------------
                // CENTER ⚥ BUTTON
                // ------------------------------
                Positioned(
                  bottom: 10,
                  child: Transform.scale(
                    scale: lerpDouble(1.0, 1.08, t)!,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.pinkAccent,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 15 * t,
                            color: Colors.black.withOpacity(0.20 * t),
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
          );
        },
      ),
    );
  }

  Widget _genderButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// FINAL PINTEREST ARC PAINTER (Arc hidden when closed)
/// ---------------------------------------------------------------------------
class ArcPainter extends CustomPainter {
  final double progress;

  ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 🔥 FIX: Arc is INVISIBLE when closed
    if (progress == 0) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final double bumpRadius = lerpDouble(0, 48, progress)!;
    final double topY = lerpDouble(h - 40, h - 115, progress)!;
    final double cx = w / 2;

    final Path path = Path()
      ..moveTo(0, h)
      ..lineTo(0, topY)
      ..lineTo(cx - bumpRadius, topY);

    if (progress > 0) {
      path.arcToPoint(
        Offset(cx + bumpRadius, topY),
        radius: Radius.circular(bumpRadius),
        clockwise: false,
      );
    }

    path
      ..lineTo(w, topY)
      ..lineTo(w, h)
      ..close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.18 * progress), 16, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
