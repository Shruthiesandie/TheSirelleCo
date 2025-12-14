class Product {
  final String id;
  final String name;
  final String category;
  final int price;
  final String thumbnail;
  final List<String> images; // ✅ ADD THIS

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.thumbnail,
    required this.images, // ✅ ADD
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      thumbnail: map['thumbnail'],
      images: (map['images'] as String).split(','), // ✅ ADD
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'thumbnail': thumbnail,
      'images': images.join(','), // ✅ ADD
    };
  }
}