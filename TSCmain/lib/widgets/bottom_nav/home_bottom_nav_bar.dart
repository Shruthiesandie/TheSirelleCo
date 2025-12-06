import 'dart:ui';

import 'package:flutter/material.dart';

typedef BottomNavTap = void Function(int index);

/// Bottom navigation bar with 5 items, equal spacing,
/// and pink highlight for selected item.
class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final BottomNavTap onItemTap;

  const HomeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 66, // reduced height to reveal curvature
          margin: const EdgeInsets.only(bottom: 22, left: 12, right: 12), // lift and reveal edges
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(32), // smoother full rounding
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(.22),
                blurRadius: 22,
                spreadRadius: 3,
                offset: const Offset(0, 6), // deeper soft elevation
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10), // moves icons inward
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // adds spacing
              children: [
                _navItem(Icons.home, 0),
                _navItem(Icons.favorite_border, 1),
                _navItem(Icons.grid_view_rounded, 2),
                _navItem(Icons.shopping_bag_outlined, 3),
                _navItem(Icons.person, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 6), // top spacing
            Icon(
              icon,
              size: 28, // reduced icon size
              color: isSelected ? Colors.pinkAccent : Colors.grey.shade500,
            ),
            SizedBox(height: 6), // bottom spacing
          ],
        ),
      ),
    );
  }
}