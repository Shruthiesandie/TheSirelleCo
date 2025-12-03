import 'package:flutter/material.dart';

class BottomCurvePainter extends CustomPainter {
  static const _radius = 46.0;
  static const _dipHeight = -32.0;

  final double x;

  BottomCurvePainter(this.x);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(x - _radius, 0)
      ..quadraticBezierTo(
        x,
        _dipHeight,
        x + _radius,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant BottomCurvePainter oldDelegate) => x != oldDelegate.x;
}
