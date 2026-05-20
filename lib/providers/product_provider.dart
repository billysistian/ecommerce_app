// lib/providers/product_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

final productProvider =
    StateNotifierProvider<ProductNotifier, List<ProductModel>>(
      (ref) => ProductNotifier(),
    );

class ProductNotifier extends StateNotifier<List<ProductModel>> {
  ProductNotifier() : super([]);

  int currentPage = 1;

  bool hasMore = true;

  bool loading = false;

  String search = '';

  String sort = 'latest';

  int? categoryId;

  Future<void> fetchProducts({bool refresh = false}) async {
    if (loading) return;

    if (!hasMore && !refresh) return;

    loading = true;

    if (refresh) {
      currentPage = 1;

      hasMore = true;

      state = [];
    }

    final response = await ProductService.getProducts(
      page: currentPage,
      search: search,
      sort: sort,
      categoryId: categoryId,
    );

    final List data = List.from(response['data'] ?? []);

    final products = data.map((e) => ProductModel.fromJson(e)).toList();

    state = [...state, ...products];

    currentPage++;

    hasMore = response['next_page_url'] != null;

    loading = false;
  }

  Future<void> setSearch(String value) async {
    search = value.trim();

    await fetchProducts(refresh: true);
  }

  Future<void> setSort(String value) async {
    sort = value;

    await fetchProducts(refresh: true);
  }

  Future<void> setCategory(int? id) async {
    categoryId = id;

    await fetchProducts(refresh: true);
  }
}
