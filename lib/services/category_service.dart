import '../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryService {
  static Future<List<CategoryModel>> getCategories() async {
    final response = await ApiClient.get('/categories');
    final List data = response.data['data'];
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }
}
