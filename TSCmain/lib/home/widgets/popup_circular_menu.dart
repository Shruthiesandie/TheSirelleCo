import 'package:flutter/material.dart';
import 'dart:math' as math;

typedef CategorySelect = void Function(String slug);

class PopupCircularMenu extends StatefulWidget {
  final bool isOpen;
  final CategorySelect onSelect;

  const PopupCircularMenu({
    super.key,
    required this.isOpen,
    required this.onSelect,
  });

  @override
  State<PopupCircularMenu> createState() => _PopupCircularMenuState();
}

class _PopupCircularMenuState extends State<PopupCircularMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _anim = CurvedAnimation(curve: Curves.easeOutBack, parent: _ctrl);

    if (widget.isOpen) _ctrl.value = 1;
  }

  @override
  void didUpdateWidget(covariant PopupCircularMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOpen) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
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

    return Positioned(
      bottom: 70,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !widget.isOpen,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) {
            double t = _anim.value;

            return Opacity(
              opacity: t,
              child: Transform.scale(
                scale: t,
                child: SizedBox(
                  width: 200,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // BACK SEMICIRCLE
                      CustomPaint(
                        size: const Size(200, 100),
                        painter: _SemiPainter(),
                      ),

                      // LEFT ICON
                      Positioned(
                        left: 40,
                        bottom: 25,
                        child: _icon(Icons.male, "male", Colors.blue),
                      ),

                      // CENTER ICON
                      Positioned(
                        bottom: 45,
                        child: _icon(Icons.transgender, "all", Colors.purple),
                      ),

                      // RIGHT ICON
                      Positioned(
                        right: 40,
                        bottom: 25,
                        child: _icon(Icons.female, "female", Colors.pink),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _icon(IconData icon, String slug, Color color) {
    return GestureDetector(
      onTap: () => widget.onSelect(slug),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Icon(icon, size: 26, color: color),
      ),
    );
  }
}

class _SemiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    Path path = Path();
    path.moveTo(0, size.height);
    path.arcTo(
        Rect.fromLTWH(0, 0, size.width, size.height * 2), math.pi, -math.pi, true);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.25), 18, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
