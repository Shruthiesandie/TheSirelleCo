// lib/home/widgets/popup_bubble_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CategoryCallback = void Function(String slug);

class PopupBubbleMenu extends StatefulWidget {
  final bool open;
  final CategoryCallback onSelect;
  final VoidCallback onClose;

  const PopupBubbleMenu({
    super.key,
    required this.open,
    required this.onSelect,
    required this.onClose,
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

    // pod inflates with a gentle overshoot
    _podGrow = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack));

    // fade in the pod slightly later
    _podFade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.05, 0.65, curve: Curves.easeIn));

    // icons appear after pod grows
    _iconsFade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.6, 1.0, curve: Curves.easeIn));
    _iconsScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.6, 1.0, curve: Curves.elasticOut)),
    );

    if (widget.open) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant PopupBubbleMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) {
      if (widget.open) {
        // small delay for tactile feel
        Future.delayed(const Duration(milliseconds: 60), () => _ctrl.forward());
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

  Widget _circleIcon({required Widget child}) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // sizing tuned to fit above the BottomNavigationBar
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    return IgnorePointer(
      ignoring: !widget.open && !_ctrl.isAnimating,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final double tGrow = _podGrow.value.clamp(0.0, 1.0);
          final double tFade = _podFade.value.clamp(0.0, 1.0);
          final double iconsOpacity = _iconsFade.value.clamp(0.0, 1.0);
          final double iconScale = _iconsScale.value.clamp(0.0, 1.0);

          return Stack(
            children: [
              // dim background
              if (tFade > 0.01)
                Opacity(
                  opacity: (0.16 * tFade).clamp(0.0, 0.16),
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Container(color: Colors.black),
                  ),
                ),

              // pod + icons
              Positioned(
                left: 0,
                right: 0,
                bottom: safeBottom + 8, // sits slightly above nav
                child: Transform.translate(
                  // slight rise effect: translate from below while growing
                  offset: Offset(0, 40 * (1 - tGrow)),
                  child: Opacity(
                    opacity: tFade,
                    child: Center(
                      child: SizedBox(
                        width: 260,
                        // pod height will grow with tGrow
                        height: 72 * (0.9 + 0.5 * tGrow),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // the rounded pod background
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Transform.scale(
                                scale: 0.98 + 0.04 * tGrow,
                                child: Container(
                                  width: 260,
                                  height: 72 * (0.9 + 0.5 * tGrow),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.14 * tFade),
                                        blurRadius: 20 * (0.8 + 0.4 * tGrow),
                                        offset: const Offset(0, -6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                                    // small inner soft gradient for kawaii look
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.98),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // icons row (positioned a bit above the top edge of pod)
                            Positioned(
                              top: 8,
                              child: Opacity(
                                opacity: iconsOpacity,
                                child: Transform.scale(
                                  scale: 0.9 + 0.1 * iconScale,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // left
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          widget.onSelect('male');
                                        },
                                        child: Transform.translate(
                                          offset: Offset(-36 * (1 - iconScale), 0),
                                          child: _circleIcon(
                                            child: Icon(Icons.male, color: const Color(0xFF4A90E2), size: 26),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 18),

                                      // center
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          widget.onSelect('all');
                                        },
                                        child: Transform.translate(
                                          offset: Offset(0, -4 * (1 - iconScale)), // center pops slightly up
                                          child: _circleIcon(
                                            child: Icon(Icons.transgender, color: const Color(0xFFE9446A), size: 26),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 18),

                                      // right
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          widget.onSelect('female');
                                        },
                                        child: Transform.translate(
                                          offset: Offset(36 * (1 - iconScale), 0),
                                          child: _circleIcon(
                                            child: Icon(Icons.female, color: const Color(0xFFFF6CB5), size: 26),
                                          ),
                                        ),
                                      ),
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
