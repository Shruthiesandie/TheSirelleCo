import 'package:flutter/foundation.dart';
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
}

class CartController {
  /// Global cart items (real-time, quantity-aware)
  static final ValueNotifier<List<Object>> items =
      ValueNotifier<List<Object>>([]);

  static String? editingHamperId;

  /// Add product to cart (increase qty if exists)
  static void add(Product product) {
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
  }

  /// Increase quantity (alias for add)
  static void increase(Product product) {
    add(product);
  }

  /// Decrease quantity (remove if reaches 0)
  static void decrease(Product product) {
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
    }
  }

  /// Remove product completely
  static void remove(Product product) {
    final list = List<Object>.from(items.value)
      ..removeWhere(
        (e) => e is CartItem && e.product.id == product.id,
      );

    items.value = list;
  }

  /// Quantity of a product
  static int quantity(Product product) {
    final item = items.value
        .firstWhere((e) => e is CartItem && e.product.id == product.id, orElse: () => CartItem(product: product, quantity: 0)) as CartItem;
    return item.quantity;
  }

  /// Check if product exists in cart
  static bool contains(Product product) {
    return items.value.any((item) => item is CartItem && item.product.id == product.id);
  }

  /// Clear cart
  static void clear() {
    items.value = [];
  }

  /// Total item count (sum of quantities)
  static int get count {
    return items.value.fold(0, (sum, item) {
      if (item is CartItem) {
        return sum + item.quantity;
      } else if (item is GiftHamper) {
        return sum + 1;
      }
      return sum;
    });
  }

  /// Total cart price (price × quantity)
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
  static void addOrUpdateHamper(GiftHamper hamper) {
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
  }

  /// Remove entire gift hamper by id
  static void removeHamper(GiftHamper hamper) {
    final list = List<Object>.from(items.value)
      ..removeWhere((e) => e is GiftHamper && e.id == hamper.id);
    items.value = list;
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