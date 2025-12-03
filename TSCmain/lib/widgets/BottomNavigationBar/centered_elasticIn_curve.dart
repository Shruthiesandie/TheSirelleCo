import 'dart:math' as math;
import 'package:flutter/material.dart';

class CenteredElasticOutCurve extends Curve {
  final double period;
  CenteredElasticOutCurve([this.period = 0.4]);

  @override
  double transform(double x) {
    return math.pow(2, -10 * x) * math.sin(x * 2 * math.pi / period) + 0.5;
  }
}

class CenteredElasticInCurve extends Curve {
  final double period;
  CenteredElasticInCurve([this.period = 0.4]);

  @override
  double transform(double x) {
    return -math.pow(2, 10 * (x - 1)) *
            math.sin((x - 1) * 2 * math.pi / period) +
        0.5;
  }
}

class LinearPointCurve extends Curve {
  final double pIn;
  final double pOut;
  LinearPointCurve(this.pIn, this.pOut);

  @override
  double transform(double x) {
    final lower = pOut / pIn;
    final upper = (1 - pOut) / (1 - pIn);
    final offset = 1 - upper;
    return x < pIn ? x * lower : x * upper + offset;
  }
}
