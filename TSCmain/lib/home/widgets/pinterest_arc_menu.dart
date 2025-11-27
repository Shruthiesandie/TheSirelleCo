// lib/widgets/pinterest_arc_menu.dart
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
  late final AnimationController _ctrl;

  bool get _isVisible => widget.isOpen || _ctrl.value > 0.0;

  @override
  void initState() {
    super.initState();
    // controller starts closed (0.0) unless widget initial state says open
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: widget.isOpen ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant PinterestArcMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOpen != widget.isOpen) {
      if (widget.isOpen) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If fully closed and not animating, don't build anything (fast exit)
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 70,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = _ctrl.value; // 0..1

          // If animation has finished closing, hide entirely.
          if (t == 0.0 && !widget.isOpen) return const SizedBox.shrink();

          final double width = lerpDouble(220, 300, t)!;
          final double height = lerpDouble(70, 180, t)!;

          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ARC BACKGROUND (only draw when t>0)
                if (t > 0.001)
                  Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.95 + 0.05 * t,
                      child: CustomPaint(
                        size: Size(width, height),
                        painter: _ArcPainter(progress: t),
                      ),
                    ),
                  ),

                // BUTTONS: left (male), center (unisex), right (female)
                // Positions animate from center outward
                Positioned(
                  bottom: lerpDouble(18, 36, t)!,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Male (left)
                      Transform.translate(
                        offset: Offset(lerpDouble(0, -70, t)!, 0),
                        child: Opacity(
                          opacity: t,
                          child: Transform.scale(
                              scale: lerpDouble(0.7, 1.0, t)!,
                              child: _circle(Icons.male, Colors.blue, widget.onMaleTap)),
                        ),
                      ),

                      SizedBox(width: lerpDouble(18, 32, t)!),

                      // Unisex (center)
                      Transform.translate(
                        offset: Offset(0, lerpDouble(18, -6, t)!),
                        child: Opacity(
                          opacity: 0.9 * t,
                          child: Transform.scale(
                            scale: lerpDouble(0.8, 1.06, t)!,
                            child: _centerCircle(),
                          ),
                        ),
                      ),

                      SizedBox(width: lerpDouble(18, 32, t)!),

                      // Female (right)
                      Transform.translate(
                        offset: Offset(lerpDouble(0, 70, t)!, 0),
                        child: Opacity(
                          opacity: t,
                          child: Transform.scale(
                              scale: lerpDouble(0.7, 1.0, t)!,
                              child: _circle(Icons.female, Colors.pink, widget.onFemaleTap)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _circle(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        // close menu then run action (small delay to allow tap effect)
        _closeAndRun(onTap);
      },
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _centerCircle() {
    return GestureDetector(
      onTap: () {
        // if you want center to toggle as well, you can expose callback
        // but HomePage currently toggles via bottom nav. We'll just do pulse.
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5CA9), Color(0xFFDE4A86)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: const Icon(Icons.transgender, color: Colors.white, size: 22),
      ),
    );
  }

  // helper to close animation and then invoke tap action
  void _closeAndRun(VoidCallback action) async {
    // reverse animation visually
    await _ctrl.reverse();
    // ask parent to close too (if parent uses isOpen)
    if (mounted) {
      // we do nothing to parent state here; HomePage toggles _menuOpen,
      // but it's helpful to call a callback if you had one. Currently we
      // just run action.
      action();
    }
  }
}

/// Painter for the arc bump. Draws nothing when progress==0.
class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    final double bump = lerpDouble(0, 62, progress)!; // how big the bump is
    final double topY = lerpDouble(h - 24, h - 130, progress)!;

    final double cx = w / 2;

    final Path path = Path()
      ..moveTo(0, h)
      ..lineTo(0, topY)
      ..quadraticBezierTo(cx, topY - bump, w, topY)
      ..lineTo(w, h)
      ..close();

    // shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.18 * progress), 12, false);
    // main fill
    canvas.drawPath(path, paint);

    // subtle stroke
    final stroke = Paint()
      ..color = Colors.black.withOpacity(0.06 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.progress != progress;
}
