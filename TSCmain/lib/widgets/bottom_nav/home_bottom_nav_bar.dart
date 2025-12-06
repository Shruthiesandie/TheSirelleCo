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
      height: 78, // slightly reduced height
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
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: isSelected ? 6 : 2, horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.pink.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 30,
              color: isSelected ? Colors.pinkAccent : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }
}