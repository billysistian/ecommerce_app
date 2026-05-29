import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;

  final VoidCallback onFilterTap;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(30),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),

            blurRadius: 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: TextField(
        controller: controller,

        onSubmitted: (value) async {
          final query = value.trim();

          if (query.isNotEmpty) {
            context.push('/search?query=$query');
          }
        },

        textInputAction: TextInputAction.search,

        decoration: InputDecoration(
          hintText: 'Search for products...',

          hintStyle: TextStyle(color: Colors.grey.shade400),

          prefixIcon: const Icon(Icons.search, color: Colors.grey),

          suffixIcon: IconButton(
            icon: const Icon(Icons.tune, color: Colors.blue),

            onPressed: onFilterTap,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),

            borderSide: BorderSide.none,
          ),

          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
