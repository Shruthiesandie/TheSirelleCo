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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: isOpen ? 70 : -200,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isOpen ? 1 : 0,
        child: _arcMenu(),
      ),
    );
  }

  Widget _arcMenu() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // ARC BACKGROUND SHAPE
        CustomPaint(
          size: const Size(200, 120),
          painter: ArcPainter(),
        ),

        // BUTTONS ON TOP OF ARC
        Positioned(
          bottom: 40,
          child: Row(
            children: [
              _genderButton(Icons.male, Colors.blue, onMaleTap),
              const SizedBox(width: 40),
              _genderButton(Icons.female, Colors.pink, onFemaleTap),
            ],
          ),
        )
      ],
    );
  }

  Widget _genderButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Icon(icon, size: 30, color: color),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();

    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, 0, size.width, size.height); // arc shape
    path.lineTo(size.width, size.height + 40);
    path.lineTo(0, size.height + 40);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
