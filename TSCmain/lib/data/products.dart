import '../models/product.dart';

final List<Product> products = [
  Product(
    id: "b1",
    name: "Bottle 1",
    thumbnail: "assets/images/bottle/b1/main.png",
    images: [
      "assets/images/bottle/b1/bottle.png",
      "assets/images/bottle/b1/bdiff1/bottle11.png",
      "assets/images/bottle/b1/bdiff1/bottle12.png",
      "assets/images/bottle/b1/bdiff1/bottle13.png",
    ],
  ),

  Product(
    id: "b2",
    name: "Bottle 2",
    thumbnail: "assets/images/bottle/b2/bottle.png",
    images: [
      "assets/images/bottle/b2/main.png",
      "assets/images/bottle/b2/bdiff2/bottle21.png",
      "assets/images/bottle/b2/bdiff2/bottle22.png",
      "assets/images/bottle/b2/bdiff2/bottle23.png",
    ],
  ),

  // 👉 repeat till b8
];