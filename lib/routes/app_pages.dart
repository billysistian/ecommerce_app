import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_routes.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/product/presentation/pages/product_detail_page.dart';
import '../features/category/presentation/pages/category_list_page.dart';
import '../features/product/presentation/pages/category_product_page.dart';
import '../features/product/presentation/pages/search_page.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/wishlist/presentation/pages/wishlist_page.dart';
import '../features/order/presentation/pages/order_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isLoginRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isLoginRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'productDetail',
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>?;
          if (product == null) {
            return const Scaffold(
              body: Center(child: Text('Product not found')),
            );
          }
          return ProductDetailPage(product: product);
        },
      ),
      GoRoute(
        path: AppRoutes.categoryList,
        name: 'categoryList',
        builder: (context, state) {
          return const CategoryListPage();
        },
      ),
      GoRoute(
        path: AppRoutes.categoryProducts,
        name: 'categoryProducts',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid category')),
            );
          }

          return CategoryProductPage(
            categoryId: extra['categoryId'],
            categoryName: extra['categoryName'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) {
          final query = state.uri.queryParameters['query'] ?? '';
          return SearchPage(initialQuery: query);
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        name: 'wishlist',
        builder: (context, state) => const WishlistPage(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (context, state) => const OrderPage(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});
