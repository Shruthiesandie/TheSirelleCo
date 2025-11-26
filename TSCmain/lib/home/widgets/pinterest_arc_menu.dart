// lib/home/widgets/pinterest_arc_menu.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

typedef CategorySelect = void Function(String slug);

class PinterestArcMenu extends StatefulWidget {
  final bool isOpen;
  final CategorySelect onSelect;

  const PinterestArcMenu({
    super.key,
    required this.isOpen,
    required this.onSelect,
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
  void didUpdateWidget(covariant PinterestArcMenu oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen && _ctrl.value == 0) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: !widget.isOpen,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _arc.value;

          return Stack(
            children: [
              GestureDetector(
                onTap: () => widget.onSelect("close"),
                child: Container(
                  color: Colors.black.withOpacity(0.18 * t),
                ),
              ),

              Positioned(
                bottom: 78,
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.scale(
                    scale: t,
                    child: CustomPaint(
                      painter: _ArcPainter(),
                      child: SizedBox(
                        width: 220,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned(
                              top: 18,
                              left: 35,
                              child: _icon(Icons.male, "male", Colors.blue),
                            ),
                            Positioned(
                              top: 0,
                              child: _icon(Icons.transgender, "all", Colors.purple),
                            ),
                            Positioned(
                              top: 18,
                              right: 35,
                              child: _icon(Icons.female, "female", Colors.pink),
                            ),
                          ],
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

    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      -30,
      size.width,
      size.height,
    );
    path.close();

    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.25),
      16,
      true,
    );

    final paint = Paint()..color = Colors.white;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
