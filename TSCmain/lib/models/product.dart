class Product {
  final String id;
  final String name;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'images': images,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      thumbnail: map['thumbnail'] as String,
      images: List<String>.from(map['images'] as List),
    );
  }

  /// Auto-calculated product price
  /// (derived from product ID / category)
  int get price {
    // Order matters: check longer prefixes first
    if (id.startsWith("ca")) return 699; // caps
    if (id.startsWith("ce")) return 899; // ceramic
    if (id.startsWith("b")) return 599;  // bottles
    if (id.startsWith("c")) return 799;  // candles
    if (id.startsWith("h")) return 349;  // hair accessories
    if (id.startsWith("k")) return 299;  // key chains
    if (id.startsWith("n")) return 399;  // nails
    if (id.startsWith("p")) return 999;  // plushies
    return 199;                          // letters / default
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}