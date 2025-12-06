import 'dart:ui';
import 'package:flutter/material.dart';

typedef BottomNavTap = void Function(int index);

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
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(26),
        topRight: Radius.circular(26),
      ),
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(Icons.home, 0),
              _navItem(Icons.favorite_border, 1),

              /// Center button — highlighted large capsule
              GestureDetector(
                onTap: () => onItemTap(2),
                child: AnimatedPadding(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  padding: EdgeInsets.only(bottom: selectedIndex == 2 ? 10 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.pinkAccent,
                          const Color(0xFFB97BFF),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.32),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              _navItem(Icons.shopping_bag_outlined, 3),
              _navItem(Icons.person, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return MouseRegion(
      onHover: (_) {},
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        splashColor: Colors.pinkAccent.withOpacity(0.18),
        onTap: () => onItemTap(index),
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.elasticOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 230),
                padding: EdgeInsets.symmetric(
                  vertical: isSelected ? 8 : 4,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pink.shade50.withOpacity(0.6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.35),
                            blurRadius: 15,
                            offset: Offset(0, 6),
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isSelected ? Colors.pinkAccent : Colors.grey.shade500,
                ),
              ),
              if (isSelected)
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.only(top: 4),
                  height: 4,
                  width: 6,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}