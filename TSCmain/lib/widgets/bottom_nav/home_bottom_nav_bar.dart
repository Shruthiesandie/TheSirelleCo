// ignore_for_file: deprecated_member_use

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
    with TickerProviderStateMixin {  // Changed from SingleTickerProvider to support multiple controllers
  
  late final AnimationController _pulseController;
  late final AnimationController _glowController;        // NEW: For radiating rings
  late final AnimationController _centerPulseController; // NEW: For breathing effect

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // NEW: Initialize glow rings (continuous)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    
    // NEW: Initialize center breathing (reversing)
    _centerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();        // NEW
    _centerPulseController.dispose(); // NEW
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

                      // UPGRADED CENTER BUTTON with glow & particles
                      _centerTransformationButton(),

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

  /// ENHANCED CENTER BUTTON - Glowing Rings & Particles
  Widget _centerTransformationButton() {
    final bool isSelected = widget.selectedIndex == 2;
    
    // Complex animation values from controllers
    final double pulseScale = 1 + (_centerPulseController.value * 0.08);
    final double glowIntensity = 0.3 + (_centerPulseController.value * 0.2);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact(); // Upgraded from light to heavy
        widget.onItemTap(2);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowController, _centerPulseController]),
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Sprung.overDamped,
            transform: Matrix4.identity()
              ..translate(0.0, isSelected ? -8.0 : 0.0, 0.0)
              ..scale(isSelected ? pulseScale : 1.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // GLOW RINGS (only when selected)
                if (isSelected) ...[
                  ...List.generate(3, (index) {
                    final double t = (_glowController.value + (index * 0.33)) % 1.0;
                    final double scale = 1 + (t * 0.5);
                    final double opacity = (1 - t) * glowIntensity;
                    
                    return Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.pinkAccent.withOpacity(opacity),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Transform.scale(
                        scale: scale,
                        child: const SizedBox.shrink(),
                      ),
                    );
                  }),
                ],
                
                // MAIN BUTTON CONTAINER
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Sprung.underDamped,
                  width: isSelected ? 52 : 48,
                  height: isSelected ? 52 : 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected
                          ? [
                              Colors.pinkAccent.shade200,
                              const Color(0xFFB97BFF),
                              Colors.pinkAccent,
                            ]
                          : [
                              Colors.pink.shade100,
                              Colors.pink.shade50,
                            ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(isSelected ? 0.5 : 0.25),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 8),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      isSelected ? Icons.grid_view_rounded : Icons.grid_view_outlined,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // PARTICLE BURST (8 particles radiating)
                if (isSelected) ...List.generate(8, (index) {
                  final double angle = (index / 8) * 2 * math.pi;
                  final double t = _centerPulseController.value;
                  final double distance = 35 + (t * 10);
                  final double size = 4 * (1 - t);
                  
                  return Positioned(
                    left: 29 + math.cos(angle) * distance * t, // Center offset
                    top: 29 + math.sin(angle) * distance * t,
                    child: Opacity(
                      opacity: 1 - t,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
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
}

// Spring physics helper for luxury feel
class Sprung extends Curve {
  final double stiffness;
  final double damping;
  
  const Sprung._(this.stiffness, this.damping);
  
  static const Sprung underDamped = Sprung._(100, 10);
  static const Sprung overDamped = Sprung._(80, 20);
  
  @override
  double transform(double t) {
    final double omega = math.sqrt(stiffness);
    final double zeta = damping / (2 * math.sqrt(stiffness));
    
    if (zeta < 1) {
      final double omegaD = omega * math.sqrt(1 - zeta * zeta);
      return 1 - 
        math.exp(-zeta * omega * t) * 
        (math.cos(omegaD * t) + (zeta * omega / omegaD) * math.sin(omegaD * t));
    } else {
      final double r1 = -omega * (zeta - math.sqrt(zeta * zeta - 1));
      final double r2 = -omega * (zeta + math.sqrt(zeta * zeta - 1));
      return 1 - 
        (math.exp(r1 * t) * r2 - math.exp(r2 * t) * r1) / (r2 - r1);
    }
  }
}