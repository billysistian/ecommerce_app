import 'package:flutter/material.dart';

import '../../product/product_detail_page.dart';

class HomeProductCard extends StatelessWidget {
  final dynamic product;

  final int index;

  const HomeProductCard({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final firstVariant = product.variants.isNotEmpty
        ? product.variants.first
        : null;

    final imageUrl =
        product.thumbnailUrl ??
        firstVariant?['image_url'] ??
        'https://via.placeholder.com/300';

    final price = firstVariant?['price']?.toString() ?? '0';

    const double rating = 4.8;

    const int reviews = 120;

    final bool hasSale = index % 2 == 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              product: {
                'id': product.id,
                'category_id': product.categoryId,
                'brand_id': product.brandId,
                'name': product.name,
                'slug': product.slug,
                'description': product.description,
                'thumbnail': product.thumbnail,
                'thumbnail_url': product.thumbnailUrl,
                'category': product.category,
                'brand': product.brand,
                'variants': product.variants,
              },
            ),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),

                        borderRadius: BorderRadius.circular(16),

                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 8,
                      right: 8,

                      child: Container(
                        padding: const EdgeInsets.all(6),

                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),

                    if (hasSale)
                      Positioned(
                        top: 8,
                        left: 8,

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.red,

                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: const Text(
                            'SALE',

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 10,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),

                  const SizedBox(width: 4),

                  const Text(
                    "$rating",

                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 4),

                  Text(
                    "($reviews)",

                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                product.name,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Rp ${double.parse(price).toInt()}",

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      if (hasSale)
                        Text(
                          "Rp ${(double.parse(price) * 1.2).toInt()}",

                          style: TextStyle(
                            fontSize: 12,

                            color: Colors.grey.shade500,

                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.all(8),

                    decoration: BoxDecoration(
                      color: Colors.blue,

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Icon(
                      Icons.add_shopping_cart,

                      color: Colors.white,

                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
