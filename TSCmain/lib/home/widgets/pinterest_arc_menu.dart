import 'package:flutter/material.dart';

class PinterestArcMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      bottom: isOpen ? 70 : -220,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isOpen ? 1 : 0,
        child: Center(
          child: SizedBox(
            width: 260,
            height: 160,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 0,
                  child: _ArcBackground(width: 220, height: 120),
                ),

                // CENTER FLOATING (+) BUTTON
                Positioned(
                  top: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.16),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.pinkAccent,
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ),

                // MALE / FEMALE ICONS
                Positioned(
                  bottom: 34,
                  child: _ArcButtons(
                    isOpen: isOpen,
                    onMaleTap: onMaleTap,
                    onFemaleTap: onFemaleTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ARC BUTTONS ANIMATION
// ---------------------------------------------------------------------------

class _ArcButtons extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onMaleTap;
  final VoidCallback onFemaleTap;

  const _ArcButtons({
    required this.isOpen,
    required this.onMaleTap,
    required this.onFemaleTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _AnimatedArcButton(
            offsetX: -64,
            isOpen: isOpen,
            icon: Icons.male,
            color: Colors.blue,
            onTap: onMaleTap,
          ),
          _AnimatedArcButton(
            offsetX: 64,
            isOpen: isOpen,
            icon: Icons.female,
            color: Colors.pink,
            onTap: onFemaleTap,
          ),
        ],
      ),
    );
  }
}

class _AnimatedArcButton extends StatelessWidget {
  final double offsetX;
  final bool isOpen;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedArcButton({
    required this.offsetX,
    required this.isOpen,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      opacity: isOpen ? 1 : 0,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 330),
        transform: Matrix4.identity()
          ..translate(isOpen ? offsetX : 0, isOpen ? -14 : 12)
          ..scale(isOpen ? 1.0 : 0.6),
        curve: Curves.easeOutBack,
        child: GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 28, color: color),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ARC BACKGROUND (Pinterest Style)
// ---------------------------------------------------------------------------

class _ArcBackground extends StatelessWidget {
  final double width;
  final double height;

  const _ArcBackground({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _ArcPainter(),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Bottom rounded container
    path.moveTo(0, size.height);
    path.lineTo(0, 30);
    path.quadraticBezierTo(
      size.width / 2,
      -20,
      size.width,
      30,
    );
    path.lineTo(size.width, size.height);
    path.close();

    // Draw main shape
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 12, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
