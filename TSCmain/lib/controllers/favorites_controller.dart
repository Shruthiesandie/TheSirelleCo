import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../config/api.dart';

class FavoritesController {
  /// UI listens to this
  static final ValueNotifier<List<Product>> items =
      ValueNotifier<List<Product>>([]);

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static String get baseUrl => ApiConfig.baseUrl;

  // ---------------- LOAD WISHLIST ----------------
  static Future<void> load() async {
    if (_uid == null) {
      items.value = [];
      return;
    }

    final res = await http.get(
      Uri.parse('$baseUrl/wishlist/$_uid'),
    );

    debugPrint('Wishlist status: ${res.statusCode}');
    debugPrint('Wishlist body: ${res.body}');

    if (res.statusCode != 200) {
      items.value = [];
      return;
    }

    final List data = jsonDecode(res.body);

    items.value = data
        .map<Product>((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------- LOAD FOR CURRENT USER (USED BY AUTH GATE) ----------------
  static Future<void> loadForCurrentUser() async {
    await load();
  }

  static bool contains(Product product) {
    return items.value.any((p) => p.uiId == product.uiId);
  }

  // ---------------- ADD ----------------
  static Future<void> add(Product product) async {
    if (_uid == null) return;

    await http.post(
      Uri.parse('$baseUrl/wishlist/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': _uid,
        'ui_id': product.uiId,
      }),
    );

    await load();
  }

  // ---------------- REMOVE ----------------
  static Future<void> remove(Product product) async {
    if (_uid == null) return;

    await http.delete(
      Uri.parse('$baseUrl/wishlist/remove'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': _uid,
        'ui_id': product.uiId,
      }),
    );

    await load();
  }

  // ---------------- TOGGLE ----------------
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