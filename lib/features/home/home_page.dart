import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/floating_bottom_nav_bar.dart';
import '../cart/cart_page.dart';
import '../category/category_list_page.dart';
import '../order/order_page.dart';
import '../product/category_product_page.dart';
import '../product/product_detail_page.dart';
import '../product/search_page.dart';
import '../profile/profile_page.dart';
import '../wishlist/wishlist_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  String selectedSort = 'latest';
  int gridColumns = 2;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productProvider.notifier).fetchProducts(refresh: true);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);
    final user = ref.watch(authProvider);

    final int cartBadgeCount = 3;

    final visibleProducts = [...products];

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
      // Mencegah bottom navigation bar & FAB ikut terdorong ke atas oleh keyboard
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: products.isEmpty && notifier.loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await notifier.fetchProducts(refresh: true);
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
                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Selamat Belanja,",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                user?.name ?? 'Guest',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
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
                                child: const Icon(
                                  Icons.notifications_none_outlined,
                                  size: 28,
                                ),
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
                      ),

                      const SizedBox(height: 24),

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

                          onSubmitted: (value) async {
                            final query = value.trim();

                            if (query.isNotEmpty) {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) =>
                                      SearchPage(initialQuery: query),
                                ),
                              );
                            }
                          },

                          textInputAction: TextInputAction.search,

                          decoration: InputDecoration(
                            hintText: "Search for products...",

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

                      const SizedBox(height: 30),

                      /// CATEGORIES HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Categories",

                            style: TextStyle(
                              fontSize: 18,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) => const CategoryListPage(),
                                ),
                              );
                            },

                            child: const Text(
                              "See All",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// CATEGORIES LIST
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

                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 12),

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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),

                                        decoration: BoxDecoration(
                                          color: Colors.white,

                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),

                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
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

                            loading: () => SizedBox(
                              height: 45,

                              child: Center(
                                child: SizedBox(
                                  width: 24,

                                  height: 24,

                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),

                            error: (error, stackTrace) => SizedBox(
                              height: 45,

                              child: Center(
                                child: Text(
                                  'Failed to load categories',

                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                          ),

                      const SizedBox(height: 30),

                      /// PROMO BANNER
                      Container(
                        width: double.infinity,

                        // Diperbesar dari 160 menjadi 180 untuk menghindari overflow
                        height: 180,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),

                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&q=80',
                            ),

                            fit: BoxFit.cover,
                          ),
                        ),

                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),

                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,

                              end: Alignment.centerRight,

                              colors: [
                                // ignore: deprecated_member_use
                                Colors.black.withOpacity(0.8),

                                Colors.transparent,
                              ],
                            ),
                          ),

                          padding: const EdgeInsets.all(20),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,

                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.blue,

                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: const Text(
                                  "NEW ARRIVAL",

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontSize: 10,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                "Sony WH-1000XM5\nHeadphones",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontSize: 20,

                                  fontWeight: FontWeight.bold,

                                  height: 1.2,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: const [
                                  Text(
                                    "Shop Now",

                                    style: TextStyle(
                                      color: Colors.white,

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  SizedBox(width: 4),

                                  Icon(
                                    Icons.arrow_forward,

                                    color: Colors.white,

                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// POPULAR ITEMS HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Popular Items",

                            style: TextStyle(
                              fontSize: 18,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    gridColumns = gridColumns == 2 ? 1 : 2;
                                  });
                                },

                                child: Container(
                                  padding: const EdgeInsets.all(4),

                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: Colors.blue.withOpacity(0.1),

                                    borderRadius: BorderRadius.circular(8),
                                  ),

                                  child: Icon(
                                    gridColumns == 2
                                        ? Icons.view_list
                                        : Icons.grid_view,

                                    color: Colors.blue,

                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// PRODUCT GRID
                      GridView.builder(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridColumns,

                          childAspectRatio: gridColumns == 2 ? 0.65 : 0.8,

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

                                        Container(
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
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      if (notifier.loading)
                        const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),

      // Floating Bottom Nav Bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
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
          // Membungkus Icon dengan widget Badge bawaan Flutter
          child: Badge(
            backgroundColor: Colors.red,
            isLabelVisible: cartBadgeCount > 0, // Hanya muncul jika count > 0
            label: Text(
              '$cartBadgeCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onHomeTap: () {
          setState(() {
            _currentIndex = 0;
          });
        },
        onSavedTap: () {
          setState(() {
            _currentIndex = 1;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WishlistPage()),
          );
        },
        onOrdersTap: () {
          setState(() {
            _currentIndex = 2;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderPage()),
          );
        },
        onProfileTap: () {
          setState(() {
            _currentIndex = 3;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        },
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
