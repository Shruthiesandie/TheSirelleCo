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
    return Container(
      height: 90, // increased height for breathing space
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _navItem(Icons.home, 0),
          _navItem(Icons.favorite_border, 1),
          _navItem(Icons.grid_view_rounded, 2),
          _navItem(Icons.shopping_bag_outlined, 3),
          _navItem(Icons.person, 4),
        ],
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
              size: 32, // slightly bigger for better proportion
              color: isSelected ? Colors.pinkAccent : Colors.grey.shade500,
            ),
            SizedBox(height: 6), // bottom spacing
          ],
        ),
      ),
    );
  }
}