import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FavoritesController {
  /// UI listens to this
  static final ValueNotifier<List<Product>> items =
      ValueNotifier<List<Product>>([]);

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static String get _storageKey =>
      _uid == null ? 'wishlist_guest' : 'wishlist_$_uid';

  /// Load wishlist for current user (call after login)
  static Future<void> loadForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) {
      items.value = [];
      return;
    }

    final List decoded = jsonDecode(raw);
    items.value =
        decoded.map((e) => Product.fromMap(e as Map<String, dynamic>)).toList();
  }

  static bool contains(Product product) {
    return items.value.any((p) => p.id == product.id);
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(items.value.map((p) => p.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static Future<void> add(Product product) async {
    if (contains(product)) return;
    items.value = [...items.value, product];
    await _persist();
  }

  static Future<void> remove(Product product) async {
    items.value = items.value.where((p) => p.id != product.id).toList();
    await _persist();
  }

  static Future<void> toggle(Product product) async {
    if (contains(product)) {
      await remove(product);
    } else {
      await add(product);
    }
  }

  /// Call on logout
  static void clear() {
    items.value = [];
  }
}