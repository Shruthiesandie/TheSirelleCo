import 'product.dart';

class GiftHamper {
  final String id;
  final List<Product> items;

  /// Stored discount (can be null from old data)
  final double? _discountPercent;

  GiftHamper({
    required this.id,
    required this.items,
    double? discountPercent,
  }) : _discountPercent = discountPercent;

  /// Always returns a valid discount percentage
  double get discountPercent => _discountPercent ?? 5.0;

  /// Total price before discount
  double get subtotal {
    return items.fold(0.0, (sum, p) {
      final double price = p.price.toDouble();
      return sum + price;
    });
  }

  /// Discount value in currency
  double get discountAmount {
    return subtotal * (discountPercent / 100);
  }

  /// Final price after discount
  double get totalPrice {
    return subtotal - discountAmount;
  }

  void removeItem(Product product) {
    items.removeWhere((p) => p.id == product.id);
  }

  void addItem(Product product) {
    if (!items.any((p) => p.id == product.id)) {
      items.add(product);
    }
  }
}