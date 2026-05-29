// lib/models/product_model.dart

class ProductModel {
  final int id;

  final int? categoryId;

  final int? brandId;

  final String name;

  final String? slug;

  final String? description;

  final String? thumbnail;

  final String? thumbnailUrl;

  final Map<String, dynamic>? category;

  final Map<String, dynamic>? brand;

  final List<dynamic> variants;

  ProductModel({
    required this.id,
    this.categoryId,
    this.brandId,
    required this.name,
    this.slug,
    this.description,
    this.thumbnail,
    this.thumbnailUrl,
    this.category,
    this.brand,
    required this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],

      categoryId: json['category_id'],

      brandId: json['brand_id'],

      name: json['name'] ?? '',

      slug: json['slug'],

      description: json['description'],

      thumbnail: json['thumbnail'],

      thumbnailUrl: json['thumbnail_url'],

      category: json['category'],

      brand: json['brand'],

      variants: List.from(json['variants'] ?? []),
    );
  }
}
