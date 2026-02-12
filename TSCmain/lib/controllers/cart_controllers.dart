import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

import '../../models/product.dart';
import '../../models/gift_hamper.dart';

/// Cart item with quantity
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
    'type': 'product',
    'product': product.toJson(),
    'quantity': quantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromJson(map['product']),
      quantity: map['quantity'] ?? 1,
    );
  }
}

class CartController {
  static final ValueNotifier<List<Object>> items =
      ValueNotifier<List<Object>>([]);

  /// Always assign a NEW list so ValueNotifier rebuilds listeners (Checkout, Cart UI, etc.)
  static void _setItems(List<Object> newItems) {
    items.value = List<Object>.from(newItems);
  }

  static String? editingHamperId;

  /// Selected delivery address for checkout (persisted per user UID)
  static final ValueNotifier<String?> selectedAddress = ValueNotifier<String?>(null)
    ..addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      final uid = _uid ?? 'guest';
      final key = 'selected_address_$uid';

      final value = selectedAddress.value;
      if (value == null || value.isEmpty) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, value);
      }
    });

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Restore last selected address for the CURRENT user
  static Future<void> restoreSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _uid ?? 'guest';
    final key = 'selected_address_$uid';

    final saved = prefs.getString(key);
    if (saved != null && saved.isNotEmpty) {
      selectedAddress.value = saved;
    } else {
      selectedAddress.value = null;
    }
  }

  /// Listen for auth changes and auto-switch address memory
  static void attachAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((_) async {
      await restoreSavedAddress();
    });
  }


  /// Load cart for current user (call after login)
  static Future<void> loadForCurrentUser() async {
    final uid = _uid;
    if (uid == null) {
      items.value = [];
      await restoreSavedAddress();
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/cart/$uid"),
      );

      if (res.statusCode != 200) {
        items.value = [];
        return;
      }

      final List data = jsonDecode(res.body);

      _setItems(data.map<Object>((e) {
        return CartItem(
          product: Product(
            productId: e['product_id'],
            uiId: e['ui_id'] ?? e['product_id'].toString(),
            name: e['name'],
            price: double.parse(e['price'].toString()),
            category: e['category'],
            imageUrl: e['image_url'],
            description: e['description'] ?? '',
          ),
          quantity: e['quantity'] ?? 1,
        );
      }).toList());
      await restoreSavedAddress();
    } catch (e) {
      items.value = [];
    }
  }

  static Future<void> _persist() async {
    // Persistence handled by backend (MySQL)
  }

  /// Add product to cart
  static Future<void> add(Product product) async {
    final uid = _uid;
    if (uid == null) return;

    await http.post(
      Uri.parse("${ApiConfig.baseUrl}/cart/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
        "ui_id": product.uiId,
      }),
    );

    await loadForCurrentUser();
  }

  static Future<void> increase(Product product) async {
    await add(product);
  }

  static Future<void> decrease(Product product) async {
    final uid = _uid;
    if (uid == null) return;

    await http.post(
      Uri.parse("${ApiConfig.baseUrl}/cart/remove"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
        "ui_id": product.uiId,
      }),
    );

    await loadForCurrentUser();
  }

  static Future<void> remove(Product product) async {
    final uid = _uid;
    if (uid == null) return;

    await http.post(
      Uri.parse("${ApiConfig.baseUrl}/cart/remove"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
        "ui_id": product.uiId,
      }),
    );

    await loadForCurrentUser();
  }

  static int quantity(Product product) {
    final item = items.value.firstWhere(
      (e) => e is CartItem && e.product.uiId == product.uiId,
      orElse: () => CartItem(product: product, quantity: 0),
    ) as CartItem;
    return item.quantity;
  }

  static bool contains(Product product) {
    return items.value.any(
      (item) => item is CartItem && item.product.uiId == product.uiId,
    );
  }

  static Future<void> clear() async {
    final uid = _uid;
    if (uid == null) return;

    await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/cart/$uid"),
    );

    _setItems([]);
  }

  static int get count {
    return items.value.fold(0, (sum, item) {
      if (item is CartItem) return sum + item.quantity;
      if (item is GiftHamper) return sum + 1;
      return sum;
    });
  }

  static int get totalPrice {
    return items.value.fold(0, (sum, item) {
      if (item is CartItem) {
        return sum + (item.product.price * item.quantity).toInt();
      } else if (item is GiftHamper) {
        return sum + item.totalPrice.toInt();
      }
      return sum;
    });
  }

  /// Add or update a gift hamper as ONE cart item
  static Future<void> addOrUpdateHamper(GiftHamper hamper) async {
    final list = List<Object>.from(items.value);

    if (editingHamperId != null) {
      final index = list.indexWhere(
        (e) => e is GiftHamper && e.id == editingHamperId,
      );

      if (index != -1) {
        list[index] = hamper;
      } else {
        list.add(hamper);
      }
    } else {
      list.add(hamper);
    }

    editingHamperId = null;
    _setItems(list);
    await _persist();
  }

  static Future<void> removeHamper(GiftHamper hamper) async {
    final list = List<Object>.from(items.value)
      ..removeWhere((e) => e is GiftHamper && e.id == hamper.id);
    _setItems(list);
    await _persist();
  }

  static GiftHamper? getHamperById(String id) {
    try {
      return items.value.firstWhere(
        (e) => e is GiftHamper && e.id == id,
      ) as GiftHamper;
    } catch (_) {
      return null;
    }
  }
}