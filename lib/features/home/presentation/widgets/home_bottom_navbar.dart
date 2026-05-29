import 'package:flutter/material.dart';

import '../../../order/presentation/pages/order_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';

import '../../../../shared/widgets/floating_bottom_nav_bar.dart';

class HomeBottomNavbar extends StatelessWidget {
  final int currentIndex;

  final Function(int) onChanged;

  const HomeBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingBottomNavBar(
      currentIndex: currentIndex,

      onTap: (index) {
        onChanged(index);
      },

      onHomeTap: () {
        onChanged(0);
      },

      onSavedTap: () {
        onChanged(1);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WishlistPage()),
        );
      },

      onOrdersTap: () {
        onChanged(2);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderPage()),
        );
      },

      onProfileTap: () {
        onChanged(3);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
      },
    );
  }
}
