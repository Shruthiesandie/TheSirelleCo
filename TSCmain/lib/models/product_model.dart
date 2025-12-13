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
    String normalize(String path) {
      if (path.startsWith('assets/')) {
        return path.replaceFirst('assets/', '');
      }
      return path;
    }

    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      mainImage: normalize(json['mainImage']),
      images: (json['images'] as List)
          .map((e) => normalize(e as String))
          .toList(),
      description: json['description'],
    );
  }
}