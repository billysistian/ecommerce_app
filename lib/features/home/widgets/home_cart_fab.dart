import 'package:flutter/material.dart';

import '../../cart/cart_page.dart';

class HomeCartFab extends StatelessWidget {
  const HomeCartFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      height: 64,
      width: 64,

      child: FloatingActionButton(
        backgroundColor: Colors.blue,
        elevation: 0,

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          );
        },

        child: Badge(
          backgroundColor: Colors.red,
          isLabelVisible: true,

          label: const Text(
            '3',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),

          child: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
