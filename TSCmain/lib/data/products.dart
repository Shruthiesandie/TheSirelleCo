import '../models/product.dart';

final List<Product> products = [
  Product(
    id: "b1",
    name: "candle 1",
    thumbnail: "assets/images/bottles/b1/candlee.png",
    images: [
      "assets/images/bottle/b1/bdiff/bottle11.png",
      "assets/images/bottle/b1/bdiff/bottle12.png",
      "assets/images/bottle/b1/bdiff/bottle13.png",
    ],
  ),

  Product(
    id: "b2",
    name: "Bottle 2",
    thumbnail: "assets/splash/candlee.png",
    images: [
      "assets/images/bottles/b2/bottle.png",
      "assets/splash/123.png",
      "assets/splash/123.png",
      "assets/splash/123.png",
    ],
  ),

  // 👉 repeat till b8
];