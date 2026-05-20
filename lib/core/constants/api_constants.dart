import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];

    if (url == null || url.isEmpty) {
      throw Exception('BASE_URL not found in .env');
    }

    return url;
  }

  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$baseUrl/$imagePath';
  }
}
