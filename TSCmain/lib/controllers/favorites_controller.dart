import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class FavoritesController {
  /// Single source of truth (reactive)
  static final ValueNotifier<List<Product>> items =
      ValueNotifier<List<Product>>([]);

  /// ---------- CORE LOGIC ----------

  static bool contains(Product product) {
    return items.value.any((p) => p.id == product.id);
  }

  static void add(Product product) {
    if (contains(product)) return;

    final updated = [...items.value, product];
    items.value = updated;
    _saveToPrefs(updated);
  }

  static void remove(Product product) {
    final updated =
        items.value.where((p) => p.id != product.id).toList();
    items.value = updated;
    _saveToPrefs(updated);
  }

  static void toggle(Product product) {
    if (contains(product)) {
      remove(product);
    } else {
      add(product);
    }
  }

  /// ---------- HELPERS ----------

  static int get count => items.value.length;

  static bool get isEmpty => items.value.isEmpty;

  static void clear() {
    items.value = [];
    _saveToPrefs([]);
  }

  /// ---------- PERSISTENCE ----------

  /// Restores favorites by matching saved IDs with the master product list.
  /// Call this ONCE after products are loaded (home / catalog / all categories).
  static Future<void> loadFromPrefs(List<Product> allProducts) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? [];

    final restored =
        allProducts.where((product) => ids.contains(product.id)).toList();

    items.value = restored;
  }

  static Future<void> _saveToPrefs(List<Product> list) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = list.map((p) => p.id).toList();
    await prefs.setStringList('favorite_ids', ids);
  }
}