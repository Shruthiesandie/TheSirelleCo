import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottiePullToRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const LottiePullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  State<LottiePullToRefresh> createState() => _LottiePullToRefreshState();
}

class _LottiePullToRefreshState extends State<LottiePullToRefresh> {
  bool _refreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _refreshing = true);
    await widget.onRefresh();
    if (mounted) {
      setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          color: Colors.transparent,
          backgroundColor: Colors.transparent,
          displacement: 70,
          onRefresh: _handleRefresh,
          child: widget.child,
        ),

        // ✅ CORRECT: Positioned is DIRECT child of Stack
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedOpacity(
              opacity: _refreshing ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: LottieBuilder.asset(
                    'assets/animation/pull_refresh.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}