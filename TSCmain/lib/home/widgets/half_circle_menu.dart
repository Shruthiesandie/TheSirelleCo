// lib/home/widgets/half_circle_menu.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CategoryCallback = void Function(String slug);

class HalfCircleMenu extends StatefulWidget {
  final bool isOpen;               // open/close externally
  final double radius;             // size of semicircle
  final CategoryCallback onSelect; // male / female / all
  final VoidCallback onClose;      // tapping outside closes

  const HalfCircleMenu({
    super.key,
    required this.isOpen,
    this.radius = 120,
    required this.onSelect,
    required this.onClose,
  });

  @override
  State<HalfCircleMenu> createState() => _HalfCircleMenuState();
}

class _HalfCircleMenuState extends State<HalfCircleMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _expand;
  late Animation<double> _iconScale;
  late Animation<double> _iconFade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _expand = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutBack,
    );

    _iconScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.40, 1.0, curve: Curves.easeOut),
      ),
    );

    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.50, 1.0, curve: Curves.easeIn),
      ),
    );

    if (widget.isOpen) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant HalfCircleMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        Future.delayed(
          const Duration(milliseconds: 80),
          () => _ctrl.forward(),
        );
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

  // reusable animated icon
  Widget _buildIcon({
    required IconData icon,
    required String slug,
    required Color color,
  }) {
    return FadeTransition(
      opacity: _iconFade,
      child: ScaleTransition(
        scale: _iconScale,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onSelect(slug);
          },
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: color),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = widget.radius * 2;
    final double h = widget.radius;

    return IgnorePointer(
      ignoring:
          !_ctrl.isCompleted && !_ctrl.isAnimating && _ctrl.value == 0,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final double t = _expand.value.clamp(0.0, 1.0);

          return Opacity(
            opacity: t,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (t > 0.01)
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      color:
                          Colors.black.withOpacity(0.18 * t.clamp(0, 1)),
                    ),
                  ),

                // SEMICIRCLE
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 75,
                  child: Transform.scale(
                    scale: t,
                    child: SizedBox(
                      width: w,
                      height: h,
                      child: CustomPaint(
                        painter: _SemiCirclePainter(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFB4F8C8),
                              Color(0xFFFFC1E3),
                            ],
                          ),
                          shadowColor:
                              Colors.black.withOpacity(0.12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Stack(
                            children: [
                              // LEFT ICON
                              Positioned(
                                left: 8,
                                top: 16,
                                child: Opacity(
                                  opacity:
                                      _iconFade.value.clamp(0, 1),
                                  child: Transform.translate(
                                    offset: Offset(
                                      -30 *
                                          (1 - _iconFade.value)
                                              .clamp(0, 1),
                                      0,
                                    ),
                                    child: _buildIcon(
                                      icon: Icons.male,
                                      slug: "male",
                                      color: const Color(0xFF2E86AB),
                                    ),
                                  ),
                                ),
                              ),

                              // CENTER ICON
                              Positioned(
                                left: (w / 2) - 28,
                                top: 4,
                                child: Opacity(
                                  opacity:
                                      _iconFade.value.clamp(0, 1),
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      10 *
                                          (1 - _iconFade.value)
                                              .clamp(0, 1),
                                    ),
                                    child: _buildIcon(
                                      icon: Icons.transgender,
                                      slug: "all",
                                      color: const Color(0xFFB93A3A),
                                    ),
                                  ),
                                ),
                              ),

                              // RIGHT ICON
                              Positioned(
                                right: 8,
                                top: 16,
                                child: Opacity(
                                  opacity:
                                      _iconFade.value.clamp(0, 1),
                                  child: Transform.translate(
                                    offset: Offset(
                                      30 *
                                          (1 - _iconFade.value)
                                              .clamp(0, 1),
                                      0,
                                    ),
                                    child: _buildIcon(
                                      icon: Icons.female,
                                      slug: "female",
                                      color: const Color(0xFFFF5C9D),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
}

class _SemiCirclePainter extends CustomPainter {
  final Gradient gradient;
  final Color shadowColor;

  _SemiCirclePainter({
    required this.gradient,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0, size.height);
    path.arcTo(
        Rect.fromLTWH(0, 0, size.width, size.height * 2),
        math.pi,
        -math.pi,
        true);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawShadow(path, shadowColor, 6, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
