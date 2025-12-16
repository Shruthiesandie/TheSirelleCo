import '../models/product.dart';

final List<Product> products = [
  Product(
    id: "b1",
    name: "Bottle 1",
    thumbnail: "assets/images/123.png",
    images: [
      "assets/images/bottles/b1/bottle.JPG",
      "assets/images/bottles/b1/bdiff1/bottle11.jpg",
      "assets/images/bottles/b1/bdiff1/bottle12.PNG",
      "assets/images/bottle/b1/bdiff1/bottle13.JPG",
    ],
  ),

  Product(
    id: "b2",
    name: "Bottle 2",
    thumbnail: "assets/splash/123.png",
    images: [
      "assets/images/bottles/b2/bottle.png",
      "assets/splash/123.png",
      "assets/splash/123.png",
      "assets/splash/123.png",
    ],
  ),

  // 👉 repeat till b8
];