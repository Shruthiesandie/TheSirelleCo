import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        'product': product.toMap(),
        'quantity': quantity,
      };

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(map['product']),
      quantity: map['quantity'] ?? 1,
    );
  }
}

class CartController {
  static final ValueNotifier<List<Object>> items =
      ValueNotifier<List<Object>>([]);

  static String? editingHamperId;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static String get _storageKey =>
      _uid == null ? 'cart_guest' : 'cart_$_uid';

  /// Load cart for current user (call after login)
  static Future<void> loadForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) {
      items.value = [];
      return;
    }

    final List decoded = jsonDecode(raw);
    items.value = decoded.map<Object>((e) {
      if (e['type'] == 'product') {
        return CartItem.fromMap(e);
      } else {
        return GiftHamper.fromMap(e);
      }
    }).toList();
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      items.value.map((e) {
        if (e is CartItem) return e.toMap();
        if (e is GiftHamper) return e.toMap();
        return {};
      }).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  /// Add product to cart
  static Future<void> add(Product product) async {
    final list = List<Object>.from(items.value);

    final index = list.indexWhere(
      (e) => e is CartItem && e.product.id == product.id,
    );

    if (index != -1) {
      (list[index] as CartItem).quantity += 1;
    } else {
      list.add(CartItem(product: product));
    }

    items.value = list;
    await _persist();
  }

  static Future<void> increase(Product product) async {
    await add(product);
  }

  static Future<void> decrease(Product product) async {
    final list = List<Object>.from(items.value);

    final index = list.indexWhere(
      (e) => e is CartItem && e.product.id == product.id,
    );

    if (index != -1) {
      final item = list[index] as CartItem;
      if (item.quantity > 1) {
        item.quantity -= 1;
      } else {
        list.removeAt(index);
      }
      items.value = list;
      await _persist();
    }
  }

  static Future<void> remove(Product product) async {
    final list = List<Object>.from(items.value)
      ..removeWhere(
        (e) => e is CartItem && e.product.id == product.id,
      );

    items.value = list;
    await _persist();
  }

  static int quantity(Product product) {
    final item = items.value.firstWhere(
      (e) => e is CartItem && e.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    ) as CartItem;
    return item.quantity;
  }

  static bool contains(Product product) {
    return items.value.any(
      (item) => item is CartItem && item.product.id == product.id,
    );
  }

  static Future<void> clear() async {
    items.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
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
    items.value = list;
    await _persist();
  }

  static Future<void> removeHamper(GiftHamper hamper) async {
    final list = List<Object>.from(items.value)
      ..removeWhere((e) => e is GiftHamper && e.id == hamper.id);
    items.value = list;
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