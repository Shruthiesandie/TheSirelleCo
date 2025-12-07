import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class LiquidChromeBackground extends StatefulWidget {
  final double height;
  const LiquidChromeBackground({super.key, this.height = 450});

  @override
  State<LiquidChromeBackground> createState() => _LiquidChromeBackgroundState();
}

class _LiquidChromeBackgroundState extends State<LiquidChromeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      assetKey: 'assets/shaders/liquid_chrome.frag',
      (context, shader, child) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return CustomPaint(
              size: Size(MediaQuery.of(context).size.width, widget.height),
              painter: _ChromePainter(
                shader,
                controller.value,
              ),
            );
          },
        );
      },
    );
  }
}

class _ChromePainter extends CustomPainter {
  final FragmentShader shader;
  final double time;

  _ChromePainter(this.shader, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, time * 6.28); // uTime
    shader.setFloat(1, size.width);  // uSize.x
    shader.setFloat(2, size.height); // uSize.y

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_) => true;
}