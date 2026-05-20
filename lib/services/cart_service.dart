import '../core/network/api_client.dart';

class CartService {
  /// GET CART
  static Future<Map<String, dynamic>?> getCart() async {
    try {
      final response = await ApiClient.get('/cart');
      return response.data;
    } catch (e) {
      return null;
    }
  }

  /// ADD TO CART
  static Future<Map<String, dynamic>> addToCart({
    required int productVariantId,
    required int qty,
  }) async {
    final response = await ApiClient.post(
      '/cart/add',
      data: {
        'product_variant_id': productVariantId,
        'qty': qty,
      },
    );

    return response.data;
  }

  /// UPDATE CART ITEM
  static Future<Map<String, dynamic>> updateCartItem({
    required int cartItemId,
    required int qty,
  }) async {
    final response = await ApiClient.put(
      '/cart/items/$cartItemId',
      data: {'qty': qty},
    );

    return response.data;
  }

  /// REMOVE CART ITEM
  static Future<void> removeCartItem(int cartItemId) async {
    await ApiClient.delete('/cart/items/$cartItemId');
  }

  /// GET CART COUNT
  static Future<int> getCartCount() async {
    try {
      final response = await ApiClient.get('/cart/count');
      return response.data['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
