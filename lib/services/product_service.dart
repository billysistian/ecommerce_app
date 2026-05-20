import '../core/network/api_client.dart';

class ProductService {
  static Future getProducts({
    int page = 1,
    String search = '',
    String sort = 'latest',
    int? categoryId,
  }) async {
    final queryParams = {'page': page, 'search': search.trim(), 'sort': sort};

    if (categoryId != null) {
      queryParams['category_id'] = categoryId;
    }

    final response = await ApiClient.get(
      '/products',
      queryParameters: queryParams,
    );

    return response.data;
  }
}
