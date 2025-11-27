import 'package:flutter/material.dart';

class PinterestArcMenu extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onMaleTap;
  final VoidCallback onFemaleTap;
  final VoidCallback onUnisexTap;

  const PinterestArcMenu({
    super.key,
    required this.isOpen,
    required this.onMaleTap,
    required this.onFemaleTap,
    required this.onUnisexTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      bottom: isOpen ? 80 : -200,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isOpen ? 1 : 0,
        child: _arcMenu(context),
      ),
    );
  }

  Widget _arcMenu(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // ARC SHAPE
          CustomPaint(
            size: const Size(260, 150),
            painter: ArcPainter(),
          ),

          // ICON BUTTONS
          Positioned(
            bottom: 55,
            child: Row(
              children: [
                _circleButton(Icons.male, Colors.blue, onMaleTap),
                const SizedBox(width: 30),
                _circleButton(Icons.female, Colors.pink, onFemaleTap),
                const SizedBox(width: 30),
                _circleButton(Icons.transgender, Colors.purple, onUnisexTap),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Icon(icon, size: 32, color: color),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Arc curve
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      size.height,
    );
    path.lineTo(size.width, size.height + 40);
    path.lineTo(0, size.height + 40);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
