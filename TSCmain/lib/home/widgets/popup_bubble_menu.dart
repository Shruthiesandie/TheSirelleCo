import 'package:flutter/material.dart';

typedef CategorySelect = void Function(String slug);

class PopupBubbleMenu extends StatelessWidget {
  final bool isOpen;
  final CategorySelect onSelect;

  const PopupBubbleMenu({
    super.key,
    required this.isOpen,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    return Positioned(
      bottom: 80, // sits above bottom nav
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: isOpen ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: AnimatedScale(
            scale: isOpen ? 1 : 0.7,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _bubbleIcon(Icons.male, "male", Colors.blue, onSelect),
                  const SizedBox(width: 18),
                  _bubbleIcon(Icons.transgender, "all", Colors.purple, onSelect),
                  const SizedBox(width: 18),
                  _bubbleIcon(Icons.female, "female", Colors.pink, onSelect),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubbleIcon(
      IconData icon, String slug, Color color, CategorySelect onSelect) {
    return GestureDetector(
      onTap: () => onSelect(slug),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
            )
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
