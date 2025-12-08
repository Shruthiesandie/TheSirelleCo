import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef BottomNavTap = void Function(int index);

class HomeBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final BottomNavTap onItemTap;

  const HomeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  State<HomeBottomNavBar> createState() => _HomeBottomNavBarState();
}

class _HomeBottomNavBarState extends State<HomeBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedPadding(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.zero,
      child: Transform.translate(
        offset: Offset.zero,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 22,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(Icons.home_rounded, 0),
                      _navItem(Icons.favorite_border, 1),

                      // Center floating action button
                      _centerButton(),

                      _navItem(Icons.shopping_bag_outlined, 3),
                      _navItem(Icons.person, 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Center highlighted circular button (Categories)
  Widget _centerButton() {
    final bool isSelected = widget.selectedIndex == 2;

    return GestureDetector(
      onTap: () => widget.onItemTap(2),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: EdgeInsets.only(bottom: isSelected ? 10 : 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.pinkAccent,
                Color(0xFFB97BFF),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.35),
                blurRadius: isSelected ? 22 : 14,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: AnimatedScale(
            scale: isSelected ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            child: const Icon(
              Icons.grid_view_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final bool isSelected = widget.selectedIndex == index;
    final bool isNeighbor = (widget.selectedIndex - index).abs() == 1;

    // Icon morph: swap outline to filled for some icons when selected
    IconData displayIcon = icon;
    if (icon == Icons.favorite_border && isSelected) {
      displayIcon = Icons.favorite;
    } else if (icon == Icons.shopping_bag_outlined && isSelected) {
      displayIcon = Icons.shopping_bag;
    }

    return MouseRegion(
      onHover: (_) {},
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.pinkAccent.withOpacity(0.18),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onItemTap(index);
        },
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final double t = _pulseController.value;
            final double wave = (math.sin(t * 2 * math.pi) + 1) / 2; // 0..1

            final double scale = isSelected
                ? 1.12
                : (isNeighbor ? 1.04 : 1.0);

            final double glowOpacity = isSelected ? (0.20 + wave * 0.15) : 0.0;
            final double blur = isSelected ? (10 + wave * 6) : 0;

            return AnimatedScale(
              scale: scale,
              duration: Duration(milliseconds: isSelected ? 360 : 230),
              curve: Curves.elasticOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: EdgeInsets.symmetric(
                      vertical: isSelected ? 8 : 4,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.pink.shade50.withOpacity(0.9)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: glowOpacity > 0
                          ? [
                              BoxShadow(
                                color: Colors.pinkAccent
                                    .withOpacity(glowOpacity),
                                blurRadius: blur,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      displayIcon,
                      size: 26,
                      color: isSelected
                          ? Colors.pinkAccent
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _labelFor(IconData icon) {
    if (icon == Icons.home_rounded) return "Home";
    if (icon == Icons.favorite_border) return "Fav";
    if (icon == Icons.shopping_bag_outlined) return "Cart";
    if (icon == Icons.person) return "Profile";
    return "";
  }
}