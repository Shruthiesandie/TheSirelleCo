import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/rendering.dart'; // for ScrollDirection

class PullToRefreshLottie extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const PullToRefreshLottie({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  State<PullToRefreshLottie> createState() => _PullToRefreshLottieState();
}

class _PullToRefreshLottieState extends State<PullToRefreshLottie>
    with SingleTickerProviderStateMixin {
  double _pullExtent = 0.0;
  bool _refreshing = false;
  bool _showLottie = false;

  static const double _triggerOffset = 70;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.metrics.pixels < 0 &&
            !_refreshing) {
          setState(() {
            _showLottie = true;
            _pullExtent = (-notification.metrics.pixels).clamp(0, 120);
          });
        }

        if (notification is UserScrollNotification &&
            notification.direction == ScrollDirection.idle) {
          if (_pullExtent >= _triggerOffset && !_refreshing) {
            _triggerRefresh();
          } else {
            _reset();
          }
        }

        return false;
      },
      child: Stack(
        children: [
          if (_showLottie)
            Positioned(
              top: 20 + (_pullExtent * 0.4),
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: SizedBox(
                    width: 56 + (_pullExtent * 0.5),
                    height: 56 + (_pullExtent * 0.5),
                    child: Lottie.asset(
                      'assets/animation/pull_refresh.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),
              ),
            ),

          widget.child,
        ],
      ),
    );
  }

  Future<void> _triggerRefresh() async {
    setState(() {
      _refreshing = true;
    });

    await widget.onRefresh();

    _reset();
  }

  void _reset() {
    if (!mounted) return;
    setState(() {
      _pullExtent = 0;
      _refreshing = false;
      _showLottie = false;
    });
  }
}