import 'package:flutter/material.dart';

class PinterestArcMenu extends StatefulWidget {
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
  State<PinterestArcMenu> createState() => _PinterestArcMenuState();
}

class _PinterestArcMenuState extends State<PinterestArcMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> arcScale;
  late Animation<double> maleSlide;
  late Animation<double> femaleSlide;
  late Animation<double> unisexSlide;
  late Animation<double> fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Background arc growth
    arcScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    );

    // Slight staggered icon slide up
    maleSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1, curve: Curves.easeOutBack)),
    );
    femaleSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1, curve: Curves.easeOutBack)),
    );
    unisexSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1, curve: Curves.easeOutBack)),
    );

    fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1),
    );
  }

  @override
  void didUpdateWidget(covariant PinterestArcMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: fadeIn.value,
            child: Transform.scale(
              scale: arcScale.value,
              child: _buildArcMenu(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArcMenu() {
    return Center(
      child: Container(
        width: 260,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(70),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Male
            Transform.translate(
              offset: Offset(-70, maleSlide.value),
              child: _circleButton(Icons.male, Colors.blue, widget.onMaleTap),
            ),

            // Female
            Transform.translate(
              offset: Offset(0, femaleSlide.value),
              child: _circleButton(Icons.female, Colors.pink, widget.onFemaleTap),
            ),

            // Unisex
            Transform.translate(
              offset: Offset(70, unisexSlide.value),
              child: _circleButton(Icons.transgender, Colors.purple, widget.onUnisexTap),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: widget.isOpen ? 1 : 0.001,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        child: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          child: Icon(icon, size: 32, color: color),
        ),
      ),
    );
  }
}
