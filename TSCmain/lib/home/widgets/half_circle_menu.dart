// lib/home/widgets/half_circle_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CategoryCallback = void Function(String slug);

class HalfCircleMenu extends StatefulWidget {
  final bool isOpen;
  final CategoryCallback onSelect;
  final VoidCallback onClose;

  const HalfCircleMenu({
    super.key,
    required this.isOpen,
    required this.onSelect,
    required this.onClose,
  });

  @override
  State<HalfCircleMenu> createState() => _HalfCircleMenuState();
}

class _HalfCircleMenuState extends State<HalfCircleMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;
  late Animation<double> _fade;
  late Animation<double> _iconFade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slide = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutBack,
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeIn,
    );

    _iconFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    if (widget.isOpen) _ctrl.value = 1;
  }

  @override
  void didUpdateWidget(covariant HalfCircleMenu oldWidget) {
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

  Widget buildIcon(IconData icon, String slug, Color color) {
    return FadeTransition(
      opacity: _iconFade,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onSelect(slug);
        },
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 26, color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double bubbleHeight = 110;
    const double barHeight = 68;

    return IgnorePointer(
      ignoring: !widget.isOpen && !_ctrl.isAnimating,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final double t = _slide.value;

          return Stack(
            children: [
              // Tap outside closes
              if (t > 0.01)
                GestureDetector(
                  onTap: widget.onClose,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: t * 0.15,
                    child: Container(color: Colors.black),
                  ),
                ),

              // THE CUTE WHITE SEMICIRCLE BUBBLE
              Positioned(
                left: 0,
                right: 0,
                bottom: (barHeight - 20) + (-100 * (1 - t)),
                child: Opacity(
                  opacity: _fade.value,
                  child: Center(
                    child: Container(
                      width: 210,
                      height: bubbleHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 18),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildIcon(Icons.male, "male",
                                    const Color(0xFF4A90E2)),
                                buildIcon(Icons.transgender, "all",
                                    const Color(0xFFE9446A)),
                                buildIcon(Icons.female, "female",
                                    const Color(0xFFFF6CB5)),
                              ],
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
}
