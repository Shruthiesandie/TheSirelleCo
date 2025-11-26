// lib/home/widgets/pinterest_arc_menu.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

typedef CategorySelect = void Function(String slug);

class PinterestArcMenu extends StatefulWidget {
  final bool isOpen;
  final CategorySelect onSelect;

  /// anchorX is the screen x-coordinate (logical pixels) where the arc
  /// should be centered (usually the center of the grid icon).
  final double anchorX;

  /// vertical distance above the bottom (in logical pixels) where arc will sit.
  final double bottomOffset;

  const PinterestArcMenu({
    super.key,
    required this.isOpen,
    required this.onSelect,
    required this.anchorX,
    this.bottomOffset = 78,
  });

  @override
  State<PinterestArcMenu> createState() => _PinterestArcMenuState();
}

class _PinterestArcMenuState extends State<PinterestArcMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _arc;
  late Animation<double> _scale;
  late Animation<double> _fade;

  // arc widget size (you can tweak if needed)
  static const double arcWidth = 220;
  static const double arcHeight = 120;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _arc = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.30, 1.0)),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.40, 1.0)),
    );

    if (widget.isOpen) _ctrl.value = 1;
  }

  @override
  void didUpdateWidget(PinterestArcMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Keep arc inside screen — returns left coordinate
  double _computeLeft(double screenWidth) {
    final double left = widget.anchorX - (arcWidth / 2);
    // clamp so arc doesn't overflow edges
    return left.clamp(8.0, screenWidth - arcWidth - 8.0);
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;

    if (!widget.isOpen && _ctrl.value == 0) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: !widget.isOpen,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _arc.value;

          return Stack(
            children: [
              // Dim background - tap to close (send "close")
              GestureDetector(
                onTap: () => widget.onSelect("close"),
                child: Container(
                  color: Colors.black.withOpacity(0.18 * t),
                ),
              ),

              // Positioned arc anchored at anchorX
              Positioned(
                bottom: widget.bottomOffset,
                left: _computeLeft(screenW),
                child: SizedBox(
                  width: arcWidth,
                  height: arcHeight,
                  child: Center(
                    child: Transform.scale(
                      scale: t,
                      child: CustomPaint(
                        painter: _ArcPainter(),
                        child: SizedBox(
                          width: arcWidth,
                          height: arcHeight,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              // Left icon — offset from arc left
                              Positioned(
                                top: 18,
                                left: 35,
                                child: _icon(Icons.male, "male", const Color(0xFF4A90E2)),
                              ),

                              // Center icon — centered relative to arc
                              Positioned(
                                top: 0,
                                left: (arcWidth / 2) - 28, // center
                                child: _icon(Icons.transgender, "all", const Color(0xFFE9446A)),
                              ),

                              // Right icon — offset from arc right
                              Positioned(
                                top: 18,
                                right: 35,
                                child: _icon(Icons.female, "female", const Color(0xFFFF6CB5)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _icon(IconData icon, String slug, Color color) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: () => widget.onSelect(slug),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.12),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // Smooth arc like Pinterest — quadratic curve with a taller control point
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      -30,
      size.width,
      size.height,
    );
    path.close();

    // shadow under arc
    canvas.drawShadow(path, Colors.black.withOpacity(0.25), 16, true);

    final paint = Paint()..color = Colors.white;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
