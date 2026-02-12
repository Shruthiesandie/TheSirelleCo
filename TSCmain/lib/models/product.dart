class Product {
  final int productId;
  final String uiId;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String description;

  Product({
    required this.productId,
    required this.uiId,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      uiId: json['ui_id'],
      name: json['name'],
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.parse(json['price'].toString()),
      category: json['category'],
      imageUrl: json['image_url'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'ui_id': uiId,
        'name': name,
        'price': price,
        'category': category,
        'image_url': imageUrl,
        'description': description,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && other.uiId == uiId;

  @override
  int get hashCode => uiId.hashCode;
}