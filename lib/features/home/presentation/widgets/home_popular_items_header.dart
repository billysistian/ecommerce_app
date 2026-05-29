import 'package:flutter/material.dart';

class HomePopularItemsHeader extends StatelessWidget {
  final int gridColumns;

  final VoidCallback onToggle;

  const HomePopularItemsHeader({
    super.key,
    required this.gridColumns,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Popular Items',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              gridColumns == 2 ? Icons.view_list : Icons.grid_view,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
