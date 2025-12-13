class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String mainImage;
  final List<String> images;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.mainImage,
    required this.images,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      mainImage: json['mainImage'],
      images: List<String>.from(json['images']),
      description: json['description'],
    );
  }
}