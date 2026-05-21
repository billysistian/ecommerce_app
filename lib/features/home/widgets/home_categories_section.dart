import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/category_provider.dart';

import '../../category/category_list_page.dart';
import '../../product/category_product_page.dart';

class HomeCategoriesSection extends ConsumerWidget {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const Text(
              'Categories',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryListPage()),
                );
              },

              child: const Text(
                'See All',

                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ref
            .watch(categoryProvider)
            .when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const SizedBox(
                    height: 45,

                    child: Center(child: Text('No categories')),
                  );
                }

                return SizedBox(
                  height: 45,

                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,

                    itemCount: categories.length,

                    separatorBuilder: (context, index) {
                      return const SizedBox(width: 12);
                    },

                    itemBuilder: (context, index) {
                      final cat = categories[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryProductPage(
                                categoryId: cat.id,

                                categoryName: cat.name,
                              ),
                            ),
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(25),

                            border: Border.all(color: Colors.grey.shade200),
                          ),

                          child: Center(
                            child: Text(
                              cat.name,

                              style: const TextStyle(
                                color: Colors.black87,

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },

              loading: () {
                return const SizedBox(
                  height: 45,

                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,

                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },

              error: (error, stackTrace) {
                return SizedBox(
                  height: 45,

                  child: Center(
                    child: Text(
                      'Failed to load categories',

                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}
