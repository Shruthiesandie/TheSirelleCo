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
}