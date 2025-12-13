import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/product_model.dart';

class ProductService {
  static List<Product>? _cache;

  /// Loads products from assets/data/products.json
  /// - Caches results to avoid reloading
  /// - Fails safely (returns empty list instead of crashing)
  static Future<List<Product>> loadProducts({bool forceReload = false}) async {
    if (_cache != null && !forceReload) {
      return _cache!;
    }

    try {
      final String response =
          await rootBundle.loadString('assets/data/products.json');

      final decoded = json.decode(response);

      if (decoded is! List) {
        throw const FormatException('products.json is not a List');
      }

      final products =
          decoded.map<Product>((e) => Product.fromJson(e)).toList();

      _cache = products;
      return products;
    } catch (e) {
      // Never crash the app because of assets / json issues
      debugPrint('❌ Failed to load products.json: $e');
      _cache = <Product>[];
      return _cache!;
    }
  }
}