import 'package:flutter/foundation.dart';
import '../../models/product.dart';

/// Cart item with quantity
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class CartController {
  /// Global cart items (real-time, quantity-aware)
  static final ValueNotifier<List<CartItem>> items =
      ValueNotifier<List<CartItem>>([]);

  /// Add product to cart (increase qty if exists)
  static void add(Product product) {
    final list = List<CartItem>.from(items.value);

    final index =
        list.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      list[index].quantity += 1;
    } else {
      list.add(CartItem(product: product));
    }

    items.value = list;
  }

  /// Increase quantity (alias for add)
  static void increase(Product product) {
    add(product);
  }

  /// Decrease quantity (remove if reaches 0)
  static void decrease(Product product) {
    final list = List<CartItem>.from(items.value);

    final index =
        list.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      if (list[index].quantity > 1) {
        list[index].quantity -= 1;
      } else {
        list.removeAt(index);
      }
      items.value = list;
    }
  }

  /// Remove product completely
  static void remove(Product product) {
    final list = List<CartItem>.from(items.value)
      ..removeWhere((item) => item.product.id == product.id);

    items.value = list;
  }

  /// Quantity of a product
  static int quantity(Product product) {
    final item = items.value
        .firstWhere((e) => e.product.id == product.id, orElse: () => CartItem(product: product, quantity: 0));
    return item.quantity;
  }

  /// Check if product exists in cart
  static bool contains(Product product) {
    return items.value.any((item) => item.product.id == product.id);
  }

  /// Clear cart
  static void clear() {
    items.value = [];
  }

  /// Total item count (sum of quantities)
  static int get count =>
      items.value.fold(0, (sum, item) => sum + item.quantity);

  /// Total cart price (price × quantity)
  static int get totalPrice {
    return items.value.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }
}