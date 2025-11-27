// lib/widgets/pinterest_arc_menu.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class PinterestArcMenu extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onMaleTap;
  final VoidCallback onFemaleTap;

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
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 420),
    );

    // main curve (easeOutBack gives a springy pop)
    _animCurve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    // subtle pulse for center button when open: repeats for as long as open
    _centerPulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.55, 1.0, curve: Curves.elasticInOut),
      ),
    );

    // start in correct position based on initial value
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

  // Helper to compute curved progress with slight extras for nicer motion
  double _progress(double t) => _animCurve.value;

  @override
  Widget build(BuildContext context) {
    // Positioned area (keeps centered above bottom nav)
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 180,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final t = _progress(_ctrl.value);
            // width/height of arc container morph
            final double width = lerpDouble(220, 300, t)!;
            final double height = lerpDouble(60, 150, t)!;
            final double topRadius = lerpDouble(30, 40, t)!;

            return Center(
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Blur + shadow background (glass-like)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(topRadius),
                          bottom: const Radius.circular(30),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: lerpDouble(0, 6, t)!, sigmaY: lerpDouble(0, 6, t)!),
                          child: Container(
                            // Transparent layer to allow blur to show
                            color: Colors.white.withOpacity(lerpDouble(0.0, 0.20, t)!),
                          ),
                        ),
                      ),
                    ),

                    // Soft shadow (below arc)
                    Positioned(
                      bottom: -4,
                      child: Opacity(
                        opacity: lerpDouble(0.0, 0.22, t)!,
                        child: Container(
                          width: width * 0.92,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),

                    // Painted arc shape (morphing using t)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MorphArcPainter(progress: t),
                      ),
                    ),

                    // Male button -> left along curved path
                    _animatedButton(
                      progress: t,
                      side: _ArcSide.left,
                      icon: Icons.male,
                      color: Colors.blue,
                      onTap: widget.onMaleTap,
                    ),

                    // Female button -> right along curved path
                    _animatedButton(
                      progress: t,
                      side: _ArcSide.right,
                      icon: Icons.female,
                      color: Colors.pink,
                      onTap: widget.onFemaleTap,
                    ),

                    // CENTER button (⚥) - pulsates when open
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

  // center circle showing ⚥
  Widget _centerButton(double progress) {
    // progress used to slightly rotate/pulse if desired
    final double scale = lerpDouble(1.0, 1.02, progress)!;
    return GestureDetector(
      onTap: () {
        // We leave center tap empty because HomePage toggles _menuOpen via bottom nav.
        // If you want center to toggle as well, send an onCenterTap callback and call it here.
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
          scale: scale,
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

  // builds animated male/female buttons that move out on a curved path
  Widget _animatedButton({
    required double progress,
    required _ArcSide side,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // center position (where buttons start) - relative center x = 0
    // target offsets in px
    final double targetX = side == _ArcSide.left ? -72 : 72;
    final double targetY = -18; // raised along arc

    // curve for motion - gives springy feeling using easeOutBack
    final double eased = Curves.easeOutBack.transform(progress.clamp(0.0, 1.0));

    final double x = lerpDouble(0, targetX, eased)!;
    final double y = lerpDouble(8, targetY, eased)!;
    final double scale = lerpDouble(0.6, 1.0, progress)!;
    final double opacity = lerpDouble(0.0, 1.0, progress)!;

    return Positioned(
      bottom: 34 + y,
      left: (side == _ArcSide.left) ? ( (150 / 2) + x - 26 ) : null,
      right: (side == _ArcSide.right) ? ( (150 / 2) - x - 26 ) : null,
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

// small enum to help layout left/right
enum _ArcSide { left, right }

// -----------------------------------------------------------------------------
// CUSTOM PAINTER: morphs the arc shape based on a progress value (0..1)
// -----------------------------------------------------------------------------
class _MorphArcPainter extends CustomPainter {
  final double progress; // 0 = closed (flat), 1 = open (tall curved)

  _MorphArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // we'll draw a rounded top container with a subtle center bump when open
    final paint = Paint()..color = Colors.white;
    final double w = size.width;
    final double h = size.height;

    // control values derived from progress
    final double topCurveDepth = lerpDouble(6, 46, progress)!; // how deep the curve dips up
    final double centerBumpWidth = lerpDouble(0, w * 0.42, progress)!;
    final double centerBumpHeight = lerpDouble(0, 36, progress)!;

    final Path path = Path();

    // start bottom-left
    path.moveTo(0, h);
    // left up to near top-left rounded
    path.lineTo(0, lerpDouble(h - 30, 18, progress)!);

    // left top corner curve to a central bump, then to right top corner
    final double leftControlX = w * 0.25;
    final double rightControlX = w * 0.75;
    final double topY = lerpDouble(h - 30, 18 - topCurveDepth / 2, progress)!;

    // Left top curve to near center-left
    path.quadraticBezierTo(leftControlX * (1 - progress), topY - topCurveDepth * (progress * 0.6),
        (w - centerBumpWidth) / 2, topY);

    // center bump (if progress > 0)
    if (progress > 0.01) {
      // left bump curve upward
      path.quadraticBezierTo(
        (w - centerBumpWidth) / 2 + centerBumpWidth * 0.12,
        topY - centerBumpHeight,
        w / 2,
        topY - centerBumpHeight * 0.95,
      );

      // right bump curve downward to right side
      path.quadraticBezierTo(
        (w + centerBumpWidth) / 2 - centerBumpWidth * 0.12,
        topY - centerBumpHeight,
        (w + centerBumpWidth) / 2,
        topY,
      );
    } else {
      // small gentle arc when closed
      path.quadraticBezierTo(w / 2, topY - 6 * progress, w, topY);
    }

    // right top corner down to bottom-right
    path.quadraticBezierTo(rightControlX + (w * (progress * 0.03)), topY + (topCurveDepth * (0.2 * progress)),
        w, lerpDouble(h - 30, 18, progress)!);

    path.lineTo(w, h);
    path.close();

    // shadow under the path: drawShadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 12 * progress, false);

    // main fill
    canvas.drawPath(path, paint);

    // subtle border line
    final border = Paint()
      ..color = Colors.black.withOpacity(0.06 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _MorphArcPainter old) => old.progress != progress;
}
