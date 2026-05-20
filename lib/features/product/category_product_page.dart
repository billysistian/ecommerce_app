import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../services/cart_service.dart';
import 'product_detail_page.dart';

class CategoryProductPage extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<CategoryProductPage> createState() =>
      _CategoryProductPageState();
}

class _CategoryProductPageState extends ConsumerState<CategoryProductPage> {
  final scrollController = ScrollController();
  final searchController = TextEditingController();
  String searchQuery = '';
  String selectedSort = 'latest';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(productProvider.notifier);
      notifier.setCategory(widget.categoryId);
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
    // Reset category filter when leaving page
    Future.microtask(() {
      ref.read(productProvider.notifier).setCategory(null);
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

    // Filter by category on client side (temporary fix for backend issue)
    visibleProducts = visibleProducts.where((product) {
      return product.categoryId == widget.categoryId;
    }).toList();

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
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),

      body: products.isEmpty && notifier.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await notifier.setCategory(widget.categoryId);
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
                    /// SEARCH
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },

                        textInputAction: TextInputAction.search,

                        decoration: InputDecoration(
                          hintText: "Search in ${widget.categoryName}...",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),

                          suffixIcon: IconButton(
                            icon: const Icon(Icons.tune, color: Colors.blue),
                            onPressed: () {
                              _showFilterSheet(context, notifier);
                            },
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),

                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

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
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                'No products found',
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

  void _showFilterSheet(BuildContext context, ProductNotifier notifier) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String tempSort = selectedSort;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  RadioListTile<String>(
                    value: 'latest',
                    groupValue: tempSort,
                    title: const Text('Latest'),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          tempSort = value;
                        });
                      }
                    },
                  ),

                  RadioListTile<String>(
                    value: 'price_asc',
                    groupValue: tempSort,
                    title: const Text('Price: Low to High'),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          tempSort = value;
                        });
                      }
                    },
                  ),

                  RadioListTile<String>(
                    value: 'price_desc',
                    groupValue: tempSort,
                    title: const Text('Price: High to Low'),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          tempSort = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempSort = 'latest';
                          });
                        },
                        child: const Text('Reset'),
                      ),

                      const Spacer(),

                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            selectedSort = tempSort;
                          });
                          await notifier.setSort(tempSort);
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
