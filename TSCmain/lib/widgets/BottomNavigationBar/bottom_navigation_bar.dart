import 'package:flutter/material.dart';
import 'bottom_curved_Painter.dart';

class AnimatedBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const AnimatedBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _xController;

  @override
  void initState() {
    _xController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _xController.value =
        _indexToPosition(widget.selectedIndex) / MediaQuery.of(context).size.width;
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
    const height = 70;

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
              painter: BackgroundCurvePainter(
                _xController.value * size.width,
                1.0,
                Colors.white,
              ),
            ),
          ),

          Positioned(
            left: (size.width - _getButtonContainerWidth()) / 2,
            width: _getButtonContainerWidth(),
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navIcon(Icons.home, 0),
                _navIcon(Icons.favorite_border, 1),
                _navIcon(Icons.grid_view, 2),
                _navIcon(Icons.shopping_cart, 3),
                _navIcon(Icons.person, 4),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final active = widget.selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _handleTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: active ? Alignment.topCenter : Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: active ? 50 : 22,
            decoration: BoxDecoration(
              color: active ? Colors.pinkAccent : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                if (active)
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.30),
                    blurRadius: 12,
                    spreadRadius: 5,
                  )
              ],
            ),
            child: Icon(
              icon,
              size: 18,
              color: active ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  double _getButtonContainerWidth() {
    double width = MediaQuery.of(context).size.width;
    return width > 420 ? 420 : width;
  }

  double _indexToPosition(int index) {
    const buttonCount = 5.0;
    final w = MediaQuery.of(context).size.width;
    final block = _getButtonContainerWidth();
    final start = (w - block) / 2;
    return start + index * (block / buttonCount) + block / (buttonCount * 2);
  }
}
