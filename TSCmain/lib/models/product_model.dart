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
      var p = path.trim();
      p = p.replaceAll('\\', '/');
      if (p.startsWith('/')) {
        p = p.substring(1);
      }
      if (p.startsWith('assets/')) {
        p = p.replaceFirst('assets/', '');
      }
      return p;
    }

    final imagesRaw = json['images'];
    final imagesList = imagesRaw is List
        ? imagesRaw.whereType<String>().map(normalize).toList()
        : <String>[];

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : 0.0,
      mainImage: json['mainImage'] is String
          ? normalize(json['mainImage'])
          : '',
      images: imagesList,
      description: json['description']?.toString() ?? '',
    );
  }
}