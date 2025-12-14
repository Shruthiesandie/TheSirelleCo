class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.thumbnail,
    required this.images,
  });

  // Convert DB row → Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      thumbnail: map['thumbnail'],
      images: (map['images'] as String).split(','),
    );
  }

  // Convert Product → DB row
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'thumbnail': thumbnail,
      'images': images.join(','),
    };
  }
}