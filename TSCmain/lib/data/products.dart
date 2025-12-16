import '../models/product.dart';

final List<Product> products = [
  Product(
    id: "b1",
    name: "Bottle 1",
    thumbnail: "assets/splash/123.png",
    images: [
      "assets/images/bottles/b1/bottle.png",
      "assets/images/bottles/b1/bdiff1/bottle11.png",
      "assets/images/bottles/b1/bdiff1/bottle12.png",
      "assets/images/bottle/b1/bdiff1/bottle13.png",
    ],
  ),

  Product(
    id: "b2",
    name: "Bottle 2",
    thumbnail: "assets/splash/bottle.png",
    images: [
      "assets/images/bottles/b2/bottle.png",
      "assets/splash/bottle.png",
      "assets/splash/123.png",
      "assets/splash/123.png",
    ],
  ),

  // 👉 repeat till b8
];