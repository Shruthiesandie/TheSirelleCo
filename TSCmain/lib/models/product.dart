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

  /// Auto-calculated product price
  /// (derived from product ID / category)
  int get price {
    if (id.startsWith("b")) return 599;   // bottles
    if (id.startsWith("c")) return 799;   // candles
    if (id.startsWith("ca")) return 699;  // caps
    if (id.startsWith("ce")) return 899;  // ceramic
    if (id.startsWith("h")) return 349;   // hair accessories
    if (id.startsWith("k")) return 299;   // key chains
    if (id.startsWith("n")) return 399;   // nails
    if (id.startsWith("p")) return 999;   // plusie
    return 199;                           // letters / default
  }
}