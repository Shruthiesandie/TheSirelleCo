// lib/widgets/pinterest_arc_menu.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class PinterestArcMenu extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onMaleTap;
  final VoidCallback onFemaleTap;

  /// Keep constructor identical so HomePage doesn't need changes.
  const PinterestArcMenu({
    super.key,
    required this.isOpen,
    required this.onMaleTap,
    required this.onFemaleTap,
  });

  @override
  State<PinterestArcMenu> createState() => _PinterestArcMenuState();
}

class _PinterestArcMenuState extends State<PinterestArcMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _animCurve;
  late final Animation<double> _centerPulse;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
      reverseDuration: const Duration(milliseconds: 420),
    );

    _animCurve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    _centerPulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.55, 1.0, curve: Curves.elasticInOut),
      ),
    );

    // start in correct state
    if (widget.isOpen) {
      _ctrl.value = 1.0;
    } else {
      _ctrl.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant PinterestArcMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOpen != widget.isOpen) {
      if (widget.isOpen) {
        _ctrl.forward();
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

  double _progress() => _animCurve.value;

  @override
  Widget build(BuildContext context) {
    // The whole positioned area above bottom nav
    return Positioned(
      bottom: 75, // moved up for a more visible arc
      left: 0,
      right: 0,
      child: SizedBox(
        height: 220, // increased to allow larger arc
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final double t = _progress(); // 0..1
            // morph sizes
            final double width = lerpDouble(220, 300, t)!;
            final double height = lerpDouble(70, 190, t)!;
            final double topRadius = lerpDouble(30, 40, t)!;

            return Center(
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Frosted blur + white layer to make arc visible
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(topRadius),
                          bottom: const Radius.circular(30),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: lerpDouble(0, 16, t)!,
                            sigmaY: lerpDouble(0, 16, t)!,
                          ),
                          child: Container(
                            color: Colors.white.withOpacity(lerpDouble(0.15, 0.55, t)!),
                          ),
                        ),
                      ),
                    ),

                    // Soft shadow under the arc
                    Positioned(
                      bottom: -6,
                      child: Opacity(
                        opacity: lerpDouble(0.0, 0.28, t)!,
                        child: Container(
                          width: width * 0.94,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),

                    // The morphing painted arc (top bump + rounded sides)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MorphArcPainter(progress: t),
                      ),
                    ),

                    // Male button (animated)
                    _buildAnimatedMenuButton(
                      progress: t,
                      parentWidth: width,
                      side: _ArcSide.left,
                      icon: Icons.male,
                      color: Colors.blue,
                      onTap: widget.onMaleTap,
                    ),

                    // Female button (animated)
                    _buildAnimatedMenuButton(
                      progress: t,
                      parentWidth: width,
                      side: _ArcSide.right,
                      icon: Icons.female,
                      color: Colors.pink,
                      onTap: widget.onFemaleTap,
                    ),

                    // Center button = ⚥ (pulses when open)
                    Positioned(
                      bottom: lerpDouble(6, 18, t),
                      child: Transform.scale(
                        scale: lerpDouble(1.0, _centerPulse.value, t)!,
                        child: _centerButton(t),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _centerButton(double progress) {
    // visually pleasing gradient for the center control
    return GestureDetector(
      onTap: () {
        // intentionally left empty so HomePage (bottom nav) remains the source of truth.
        // If you'd like the center to toggle too, we can add an onCenterTap callback.
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5CA9), Color(0xFFDE4A86)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18 * progress),
              blurRadius: 18 * progress,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.pink.withOpacity(0.06 * progress),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Transform.scale(
          scale: lerpDouble(1.0, 1.02, progress)!,
          child: const Text(
            "⚥",
            style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuButton({
    required double progress,
    required double parentWidth,
    required _ArcSide side,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // target positions relative to center
    final double targetX = side == _ArcSide.left ? -58 : 58; // slightly closer
    final double targetY = -36; // raise higher on arc
    // eased movement for more springy feel
    final double eased = Curves.easeOutBack.transform(progress.clamp(0.0, 1.0));
    final double x = lerpDouble(0, targetX, eased)!;
    final double y = lerpDouble(8, targetY, eased)!;
    final double scale = lerpDouble(0.6, 1.0, progress)!;
    final double opacity = lerpDouble(0.0, 1.0, progress)!;

    // center of container (left coordinate reference)
    final double centerX = parentWidth / 2;

    // left coordinate for the button (so both sides use same calculation)
    final double left = centerX + x - 26; // minus radius

    return Positioned(
      bottom: 34 + y,
      left: left,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(icon, color: color, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}

/// small enum to help side direction
enum _ArcSide { left, right }

/// Custom painter that morphs a rounded top container with a center bump.
/// progress = 0 (closed/flat) -> 1 (open/tall bump)
class _MorphArcPainter extends CustomPainter {
  final double progress;

  _MorphArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final double w = size.width;
    final double h = size.height;

    final double topCurveDepth = lerpDouble(10, 70, progress)!;
    final double centerBumpWidth = lerpDouble(0, w * 0.58, progress)!;
    final double centerBumpHeight = lerpDouble(0, 62, progress)!;

    final Path path = Path();

    // bottom-left
    path.moveTo(0, h);

    // left vertical up to top region (morph)
    path.lineTo(0, lerpDouble(h - 30, 18, progress)!);

    // left control and curve towards center left
    final double leftControlX = w * 0.20;
    final double rightControlX = w * 0.80;
    final double topY = lerpDouble(h - 30, 18 - topCurveDepth / 2, progress)!;

    path.quadraticBezierTo(
      leftControlX * (1 - progress),
      topY - topCurveDepth * (progress * 0.6),
      (w - centerBumpWidth) / 2,
      topY,
    );

    // center bump when open
    if (progress > 0.01) {
      path.quadraticBezierTo(
        (w - centerBumpWidth) / 2 + centerBumpWidth * 0.12,
        topY - centerBumpHeight,
        w / 2,
        topY - centerBumpHeight * 0.95,
      );

      path.quadraticBezierTo(
        (w + centerBumpWidth) / 2 - centerBumpWidth * 0.12,
        topY - centerBumpHeight,
        (w + centerBumpWidth) / 2,
        topY,
      );
    } else {
      // gentle arc when closed
      path.quadraticBezierTo(w / 2, topY - 6 * progress, w, topY);
    }

    // right top to right side
    path.quadraticBezierTo(
      rightControlX + (w * (progress * 0.03)),
      topY + (topCurveDepth * (0.2 * progress)),
      w,
      lerpDouble(h - 30, 18, progress)!,
    );

    // close to bottom-right
    path.lineTo(w, h);
    path.close();

    // shadow under the path
    if (progress > 0.01) {
      canvas.drawShadow(path, Colors.black.withOpacity(0.22), 14 * progress, false);
    }

    // main fill
    canvas.drawPath(path, paint);

    // subtle border
    final border = Paint()
      ..color = Colors.black.withOpacity(0.06 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _MorphArcPainter old) => old.progress != progress;
}
