import 'package:flutter/material.dart';
import '../models/product.dart';

class HamperBuilderController {
  /// Temporary selected products while building a gift hamper
  static final ValueNotifier<List<Product>> selectedItems =
      ValueNotifier<List<Product>>([]);

  /// Add or remove a product from the hamper selection
  static void toggle(Product product) {
    final List<Product> updated = List.from(selectedItems.value);

    if (updated.contains(product)) {
      updated.remove(product);
    } else {
      updated.add(product);
    }

    selectedItems.value = updated;
  }

  /// Clear selection (used after adding hamper to cart)
  static void clear() {
    selectedItems.value = [];
  }
}