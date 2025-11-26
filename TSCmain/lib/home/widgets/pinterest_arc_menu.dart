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
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0)),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0)),
    );

    if (widget.isOpen) _ctrl.value = 1.0;
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

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.isOpen,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _arc.value;
          if (t == 0) return const SizedBox.shrink();

          return Stack(
            children: [
              // close tap
              GestureDetector(
                onTap: () => widget.onSelect("close"),
                child: Container(
                  color: Colors.black.withOpacity(0.15 * t),
                ),
              ),

              // Arc popup
              Positioned(
                left: 0,
                right: 0,
                bottom: 82,
                child: Center(
                  child: Transform.scale(
                    scale: t,
                    child: CustomPaint(
                      painter: _ArcPainter(),
                      child: Container(
                        width: 200,
                        height: 110,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 18),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildIcon(Icons.male, "male", Colors.blue),
                            const SizedBox(width: 25),
                            _buildIcon(Icons.transgender, "all", Colors.purple),
                            const SizedBox(width: 25),
                            _buildIcon(Icons.female, "female", Colors.pink),
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

  Widget _buildIcon(IconData icon, String slug, Color color) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: () => widget.onSelect(slug),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.1),
                  blurRadius: 10,
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
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();

    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      -20,
      size.width,
      size.height,
    );
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 12, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
