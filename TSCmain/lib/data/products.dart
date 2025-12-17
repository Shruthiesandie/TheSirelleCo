import '../models/product.dart';

final List<Product> products = [
  Product(
    id: "b1",
    name: "candle 1",
    thumbnail: "assets/images/bottles/b1/12345.png",
    images: [
      "assets/images/candle/c1/glass1.png",
      "assets/images/candle/c1/cdiff1/glass11.png",
      "assets/images/candle/c1/cdiff1/glass12.png",
      "assets/images/candle/c1/cdiff1/glass13.png",
    ],
  ),

  Product(
    id: "b2",
    name: "Bottle 2",
    thumbnail: "assets/splash/456.png",
    images: [
      "assets/images/bottles/b2/bottle.png",
      "assets/splash/123.png",
      "assets/splash/123.png",
      "assets/splash/123.png",
    ],
  ),

  // 👉 repeat till b8
];