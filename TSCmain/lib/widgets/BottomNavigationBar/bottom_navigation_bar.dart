import 'package:flutter/material.dart';
import 'bottom_curved_painter.dart';

class AnimatedBottomBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const AnimatedBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<AnimatedBottomBar> createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _xController;

  @override
  void initState() {
    _xController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..addListener(() => setState(() {}));

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _xController.value = _indexToPosition(widget.selectedIndex) / MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  void _handleTap(int index) {
    widget.onTap(index);

    _xController.animateTo(
      _indexToPosition(index) / MediaQuery.of(context).size.width,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _xController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double height = 70.0;

    return SizedBox(
      width: size.width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            width: size.width,
            height: height - 8,
            child: CustomPaint(
              painter: BottomCurvePainter(
                _xController.value * size.width,
              ),
            ),
          ),
          Positioned(
            left: (size.width - _buttonContainerWidth(size.width)) / 2,
            top: 0,
            width: _buttonContainerWidth(size.width),
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _icon(Icons.home, 0),
                _icon(Icons.favorite_border, 1),
                _icon(Icons.grid_view, 2),
                _icon(Icons.shopping_cart, 3),
                _icon(Icons.person, 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, int index) {
    final active = widget.selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _handleTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          alignment: active ? Alignment.topCenter : Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: active ? 48 : 22,
            decoration: BoxDecoration(
              color: active ? Colors.pinkAccent : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                if (active)
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 4,
                  )
              ],
            ),
            child: Icon(icon, size: 18, color: active ? Colors.white : Colors.grey),
          ),
        ),
      ),
    );
  }

  double _indexToPosition(int index) {
    const count = 5;
    final width = MediaQuery.of(context).size.width;
    final btnWidth = _buttonContainerWidth(width);
    final start = (width - btnWidth) / 2;
    return start + index * (btnWidth / count) + btnWidth / (count * 2);
  }

  double _buttonContainerWidth(double width) => width > 420 ? 420 : width;
}
