import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final dynamic user;

  const HomeHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Belanja,',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              user?.name ?? 'Guest',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_outlined, size: 28),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
