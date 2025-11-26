// lib/home/widgets/popup_bubble_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CategorySelect = void Function(String slug);

class PopupBubbleMenu extends StatefulWidget {
  final bool isOpen;
  final CategorySelect onSelect;
  final VoidCallback? onClose;

  const PopupBubbleMenu({
    super.key,
    required this.isOpen,
    required this.onSelect,
    this.onClose,
  });

  @override
  State<PopupBubbleMenu> createState() => _PopupBubbleMenuState();
}

class _PopupBubbleMenuState extends State<PopupBubbleMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _podGrow; // 0..1
  late final Animation<double> _podFade;
  late final Animation<double> _iconsFade;
  late final Animation<double> _iconsScale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    // pod inflates (back overshoot)
    _podGrow = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
    );

    // pod fade slightly later
    _podFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.05, 0.65, curve: Curves.easeIn),
    );

    // icons appear after pod
    _iconsFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.60, 1.0, curve: Curves.easeIn),
    );

    _iconsScale = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.60, 1.0, curve: Curves.elasticOut)),
    );

    if (widget.isOpen) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant PopupBubbleMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        // small tactile delay
        Future.delayed(const Duration(milliseconds: 60), () {
          if (mounted) _ctrl.forward();
        });
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

  Widget _circleIcon(IconData icon, String slug, Color color, double iconsOpacity, double iconsScale, double xOffset) {
    // iconsOpacity and iconsScale already clamped upstream
    return Opacity(
      opacity: iconsOpacity.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(xOffset * (1 - iconsScale.clamp(0.0, 1.0)), 0),
        child: Transform.scale(
          scale: iconsScale.clamp(0.0, 1.5),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onSelect(slug);
            },
            child: Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10 * (iconsOpacity.clamp(0.0, 1.0))),
                    blurRadius: 10 * (0.6 + 0.4 * iconsOpacity.clamp(0.0, 1.0)),
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, size: 26, color: color),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // safe bottom / default nav height used to anchor the pod above the nav bar
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    final double navHeight = kBottomNavigationBarHeight; // default 56
    // position a little above nav: tweak the -10 if you want it closer/further
    final double bottomOffset = safeBottom + navHeight - 10;

    return IgnorePointer(
      ignoring: !widget.isOpen && !_ctrl.isAnimating,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final double podGrow = _podGrow.value.clamp(0.0, 1.0);
          final double podFade = _podFade.value.clamp(0.0, 1.0);
          final double iconsOpacity = _iconsFade.value.clamp(0.0, 1.0);
          final double iconsScale = _iconsScale.value.clamp(0.0, 1.0);

          return Stack(
            children: [
              // dim backdrop that closes on tap
              if (podFade > 0.01)
                Opacity(
                  opacity: (0.16 * podFade).clamp(0.0, 0.16),
                  child: GestureDetector(
                    onTap: () {
                      widget.onClose?.call();
                    },
                    child: Container(color: Colors.black),
                  ),
                ),

              // pod + icons — anchored above bottom nav
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomOffset,
                child: Transform.translate(
                  // gentle rise while growing
                  offset: Offset(0, 40 * (1 - podGrow)),
                  child: Opacity(
                    opacity: podFade,
                    child: Center(
                      child: SizedBox(
                        width: 260,
                        height: 72 * (0.90 + 0.45 * podGrow), // grows slightly with podGrow
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // pod background
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Transform.scale(
                                scale: 0.98 + 0.04 * podGrow,
                                child: Container(
                                  width: 260,
                                  height: 72 * (0.90 + 0.45 * podGrow),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity((0.14 * podFade).clamp(0.0, 0.4)),
                                        blurRadius: (16 * (0.8 + 0.4 * podGrow)).clamp(0.0, 40),
                                        offset: const Offset(0, -6),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // icons row positioned slightly above top edge of pod
                            Positioned(
                              top: 8,
                              child: Opacity(
                                opacity: iconsOpacity,
                                child: Transform.scale(
                                  scale: 0.9 + 0.1 * iconsScale,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _circleIcon(Icons.male, 'male', const Color(0xFF4A90E2), iconsOpacity, iconsScale, -36),
                                      const SizedBox(width: 18),
                                      _circleIcon(Icons.transgender, 'all', const Color(0xFFE9446A), iconsOpacity, iconsScale, 0),
                                      const SizedBox(width: 18),
                                      _circleIcon(Icons.female, 'female', const Color(0xFFFF6CB5), iconsOpacity, iconsScale, 36),
                                    ],
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
          );
        },
      ),
    );
  }
}
