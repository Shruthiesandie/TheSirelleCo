import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product_model.dart';

class ProductService {
  static Future<List<Product>> loadProducts() async {
    final String response =
        await rootBundle.loadString('assets/data/products.json');

    final List<dynamic> data = json.decode(response);

    return data.map((e) => Product.fromJson(e)).toList();
  }
}