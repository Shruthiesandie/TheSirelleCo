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
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void didUpdateWidget(PinterestArcMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOpen) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;

        // ❌ If closed → hide completely
        if (t == 0) return const SizedBox.shrink();

        return Positioned(
          bottom: 70,
          left: 0,
          right: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ----------------------------
              // ARC BACKGROUND
              // ----------------------------
              Transform.scale(
                scale: t,
                child: CustomPaint(
                  size: const Size(260, 140),
                  painter: ArcPainter(progress: t),
                ),
              ),

              // ----------------------------
              // 3 BUTTONS
              // ----------------------------
              Positioned(
                bottom: 40 * t,
                child: Row(
                  children: [
                    Transform.translate(
                      offset: Offset(-60 * t, 0),
                      child: _circle(Icons.male, Colors.blue, widget.onMaleTap),
                    ),
                    const SizedBox(width: 40),
                    Transform.translate(
                      offset: Offset(0, -12 * t),
                      child: _circle(Icons.transgender, Colors.purple,
                          widget.onUnisexTap),
                    ),
                    const SizedBox(width: 40),
                    Transform.translate(
                      offset: Offset(60 * t, 0),
                      child: _circle(
                          Icons.female, Colors.pink, widget.onFemaleTap),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _circle(IconData icon, Color color, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  final double progress;
  ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // prevent drawing when closed
    if (progress == 0) return;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    double w = size.width;
    double h = size.height;

    double bump = lerpDouble(0, 70, progress)!;
    double topY = lerpDouble(h - 20, h - 110, progress)!;

    Path path = Path();
    path.moveTo(0, h);
    path.lineTo(0, topY);
    path.quadraticBezierTo(w / 2, topY - bump, w, topY);
    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
