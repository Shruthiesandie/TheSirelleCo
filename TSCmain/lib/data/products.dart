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
    thumbnail: "assets/images/bottles/b2/bottle2.png",
    images: [
      "assets/images/bottle/b2/bdiff/bottle21.png",
      "assets/images/bottle/b2/bdiff/bottle22.png",
      "assets/images/bottle/b2/bdiff/bottle23.png",
      "assets/images/bottle/b2/bdiff/bottle24.png",
    ],
  ),

  // 👉 repeat till b8
];