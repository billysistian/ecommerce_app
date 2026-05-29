import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/product_provider.dart';
import '../../../cart/data/services/cart_service.dart';

class SearchPage extends ConsumerStatefulWidget {
  final String initialQuery;
  const SearchPage({super.key, required this.initialQuery});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final scrollController = ScrollController();
  final searchController = TextEditingController();
  String searchQuery = '';
  String selectedSort = 'latest';

  @override
  void initState() {
    super.initState();
    searchQuery = widget.initialQuery;
    searchController.text = widget.initialQuery;

    Future.microtask(() {
      final notifier = ref.read(productProvider.notifier);
      notifier.setSearch(widget.initialQuery);
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 300) {
        ref.read(productProvider.notifier).fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();

    // Reset search filter when leaving page
    Future.microtask(() {
      ref.read(productProvider.notifier).setSearch('');
    });

    super.dispose();
  }

  Future<void> _addToCart(dynamic product) async {
    if (product.variants.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No variants available')),
        );
      }
      return;
    }

    final firstVariant = product.variants.first;
    final variantId = firstVariant['id'];
    if (variantId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid variant')),
        );
      }
      return;
    }

    try {
      await CartService.addToCart(
        productVariantId: int.parse(variantId.toString()),
        qty: 1,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to cart'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);
    var visibleProducts = products;
    final query = searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      visibleProducts = visibleProducts.where((product) {
        final name = product.name.toLowerCase();
        final description = product.description?.toLowerCase() ?? '';
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    if (selectedSort == 'price_asc') {
      visibleProducts.sort((a, b) {
        final aPrice =
            double.tryParse(
              a.variants.isNotEmpty
                  ? a.variants.first['price']?.toString() ?? '0'
                  : '0',
            ) ??
            0;
        final bPrice =
            double.tryParse(
              b.variants.isNotEmpty
                  ? b.variants.first['price']?.toString() ?? '0'
                  : '0',
            ) ??
            0;
        return aPrice.compareTo(bPrice);
      });
    } else if (selectedSort == 'price_desc') {
      visibleProducts.sort((a, b) {
        final aPrice =
            double.tryParse(
              a.variants.isNotEmpty
                  ? a.variants.first['price']?.toString() ?? '0'
                  : '0',
            ) ??
            0;

        final bPrice =
            double.tryParse(
              b.variants.isNotEmpty
                  ? b.variants.first['price']?.toString() ?? '0'
                  : '0',
            ) ??
            0;
        return bPrice.compareTo(aPrice);
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),

        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },

            onSubmitted: (value) async {
              setState(() {
                searchQuery = value.trim();
              });
              await notifier.setSearch(searchQuery);
            },

            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: "Search products...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ),
        centerTitle: false,
      ),

      body: products.isEmpty && notifier.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await notifier.setSearch(searchQuery);
              },
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PRODUCT COUNT
                    Text(
                      '${visibleProducts.length} Products',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// PRODUCT GRID
                    if (visibleProducts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                'No products found for "$searchQuery"',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: visibleProducts.length,
                        itemBuilder: (context, index) {
                          final product = visibleProducts[index];
                          final firstVariant = product.variants.isNotEmpty
                              ? product.variants.first
                              : null;
                          final imageUrl =
                              product.thumbnailUrl ??
                              firstVariant?['image_url'] ??
                              'https://via.placeholder.com/300';
                          final price =
                              firstVariant?['price']?.toString() ?? '0';

                          double rating = 4.8;
                          int reviews = 120;
                          bool hasSale = index % 2 == 1;

                          return GestureDetector(
                            onTap: () {
                              context.push(
                                '/product-detail',
                                extra: {
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
                              );
                            },

                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
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
                                    /// IMAGE STACK
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(16),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),

                                                child: const Text(
                                                  "SALE",
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

                                    /// RATING
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 14,
                                        ),

                                        const SizedBox(width: 4),

                                        Text(
                                          "$rating",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(width: 4),

                                        Text(
                                          "($reviews)",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    /// PRODUCT NAME
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

                                    /// PRICE & CART BUTTON
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                          ],
                                        ),

                                        GestureDetector(
                                          onTap: () => _addToCart(product),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.add_shopping_cart,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    if (notifier.loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
