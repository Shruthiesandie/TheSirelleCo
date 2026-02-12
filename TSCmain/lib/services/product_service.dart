import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String baseUrl = 'http://127.0.0.1:3000';
  static int _rotation = 0;

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final products = data.map((e) => Product.fromJson(e)).toList();

      // 🔄 FORCE DIFFERENT ORDER ON EVERY FETCH
      _rotation++;
      if (products.length > 1) {
        final shift = _rotation % products.length;
        final rotated = [
          ...products.sublist(shift),
          ...products.sublist(0, shift),
        ];
        return rotated;
      }
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }
}