import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesController {
  // Single source of truth
  static final ValueNotifier<List<Product>> items =
      ValueNotifier<List<Product>>([]);

  static bool contains(Product product) {
    return items.value.contains(product);
  }

  static void add(Product product) {
    if (!contains(product)) {
      items.value = [...items.value, product];
    }
  }

  static void remove(Product product) {
    items.value = items.value.where((p) => p.id != product.id).toList();
  }

  static void toggle(Product product) {
    if (contains(product)) {
      remove(product);
    } else {
      add(product);
    }
  }

  static void clear() {
    items.value = [];
  }
}