import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';

import '../widgets/home_bottom_navbar.dart';
import '../widgets/home_cart_fab.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/home_filter_sheet.dart';
import '../widgets/home_header.dart';
import '../widgets/home_popular_items_header.dart';
import '../widgets/home_product_card.dart';
import '../widgets/home_promo_banner.dart';
import '../widgets/search_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const double _scrollThreshold = 300;
  static const double _horizontalPadding = 24;
  static const double _verticalPadding = 20;
  static const double _gridSpacing = 16;
  static const double _bottomSpacing = 80;

  static const String _sortLatest = 'latest';
  static const String _sortPriceAsc = 'price_asc';
  static const String _sortPriceDesc = 'price_desc';

  final searchController = TextEditingController();
  final scrollController = ScrollController();

  String selectedSort = _sortLatest;

  int gridColumns = 2;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(productProvider.notifier).fetchProducts(refresh: true);
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - _scrollThreshold) {
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

  double extractPrice(dynamic product) {
    if (product.variants.isNotEmpty) {
      return double.tryParse(
            product.variants.first['price']?.toString() ?? '0',
          ) ??
          0;
    }

    return 0;
  }

  void showFilterSheet(ProductNotifier notifier) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return HomeFilterSheet(
          selectedSort: selectedSort,
          onApply: (value) async {
            setState(() {
              selectedSort = value;
            });

            await notifier.setSort(value);

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);

    final notifier = ref.read(productProvider.notifier);

    final user = ref.watch(authProvider);

    final visibleProducts = [...products];

    if (selectedSort == _sortPriceAsc) {
      visibleProducts.sort(
        (a, b) => extractPrice(a).compareTo(extractPrice(b)),
      );
    } else if (selectedSort == _sortPriceDesc) {
      visibleProducts.sort(
        (a, b) => extractPrice(b).compareTo(extractPrice(a)),
      );
    }

    return Scaffold(
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
                    horizontal: _horizontalPadding,
                    vertical: _verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeHeader(user: user),

                      const SizedBox(height: 24),

                      HomeSearchBar(
                        controller: searchController,
                        onFilterTap: () {
                          showFilterSheet(notifier);
                        },
                      ),

                      const SizedBox(height: 24),

                      const HomeCategoriesSection(),

                      const SizedBox(height: 30),

                      const HomePromoBanner(),

                      const SizedBox(height: 30),

                      HomePopularItemsHeader(
                        gridColumns: gridColumns,
                        onToggle: () {
                          setState(() {
                            gridColumns = gridColumns == 2 ? 1 : 2;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridColumns,
                          childAspectRatio: gridColumns == 2 ? 0.65 : 0.8,
                          crossAxisSpacing: _gridSpacing,
                          mainAxisSpacing: _gridSpacing,
                        ),
                        itemCount: visibleProducts.length,
                        itemBuilder: (context, index) {
                          return HomeProductCard(
                            product: visibleProducts[index],
                            index: index,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      if (notifier.loading)
                        const Center(child: CircularProgressIndicator()),

                      const SizedBox(height: _bottomSpacing),
                    ],
                  ),
                ),
              ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: const HomeCartFab(),

      bottomNavigationBar: HomeBottomNavbar(
        currentIndex: currentIndex,
        onChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
      ),
    );
  }
}
