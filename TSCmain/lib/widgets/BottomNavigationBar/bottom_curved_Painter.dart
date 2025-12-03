import 'package:flutter/material.dart';
import 'centered_elasticIn_curve.dart';

class BackgroundCurvePainter extends CustomPainter {
  static const _radiusTop = 45.0;
  static const _radiusBottom = 28.0;

  static const _pointControlTop = 0.28;
  static const _pointControlBottom = 0.78;

  static const _horizontalControlTop = 0.6;
  static const _horizontalControlBottom = 0.55;

  static const _topY = -32.0;
  static const _bottomY = 0.0;
  static const _topDistance = 0.0;
  static const _bottomDistance = 6.0;

  final double _x;
  final double _normalizedY;
  final Color _color;

  BackgroundCurvePainter(this._x, this._normalizedY, this._color);

  @override
  void paint(Canvas canvas, Size size) {
    final norm = _normalizedY;

    final radius = Tween(begin: _radiusTop, end: _radiusBottom).transform(norm);

    final anchorControlOffset = Tween(
      begin: radius * _horizontalControlTop,
      end: radius * _horizontalControlBottom,
    ).transform(norm);

    final dipOffset = Tween(
      begin: radius * _pointControlTop,
      end: radius * _pointControlBottom,
    ).transform(norm);

    final y = Tween(begin: _topY, end: _bottomY).transform(norm);
    final dist = Tween(begin: _topDistance, end: _bottomDistance).transform(norm);

    final x0 = _x - dist / 2;
    final x1 = _x + dist / 2;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(x0 - radius, 0)
      ..cubicTo(
        x0 - radius + anchorControlOffset,
        0,
        x0 - dipOffset,
        y,
        x0,
        y,
      )
      ..lineTo(x1, y)
      ..cubicTo(
        x1 + dipOffset,
        y,
        x1 + radius - anchorControlOffset,
        0,
        x1 + radius,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    canvas.drawPath(path, Paint()..color = _color);
  }

  @override
  bool shouldRepaint(covariant BackgroundCurvePainter oldDelegate) {
    return _x != oldDelegate._x ||
        _normalizedY != oldDelegate._normalizedY ||
        _color != oldDelegate._color;
  }
}
