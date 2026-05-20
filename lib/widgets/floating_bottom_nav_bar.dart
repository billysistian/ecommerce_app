import 'package:flutter/material.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onHomeTap;
  final VoidCallback? onSavedTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onProfileTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onHomeTap,
    this.onSavedTap,
    this.onOrdersTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0, onHomeTap),
            _buildNavItem(Icons.favorite_border, "Saved", 1, onSavedTap),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(Icons.shopping_bag_outlined, "Orders", 2, onOrdersTap),
            _buildNavItem(Icons.person_outline, "Profile", 3, onProfileTap),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, VoidCallback? onTapCallback) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: onTapCallback ?? () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.grey.shade400),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey.shade500,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
