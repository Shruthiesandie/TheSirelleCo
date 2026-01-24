import 'package:flutter/material.dart';
import '../models/product.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/hamper_builder_controller.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final bool isHamperMode;
  final VoidCallback? onSelect;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.isHamperMode = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: FavoritesController.items,
      builder: (context, favorites, _) {
        final isFav = FavoritesController.contains(product);

        return GestureDetector(
          onTap: isHamperMode ? onSelect : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE + HEART
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(14)),
                          child: Image.asset(
                            product.thumbnail,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.pink,
                          ),
                          onPressed: () {
                            FavoritesController.toggle(product);
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.thumbnail.split("/")[2]
                                .replaceAll("_", " ")
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (isHamperMode)
                        ValueListenableBuilder<List<Product>>(
                          valueListenable: HamperBuilderController.selectedItems,
                          builder: (_, selected, __) {
                            if (!selected.contains(product)) return const SizedBox.shrink();

                            return Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.pinkAccent,
                                  size: 22,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // INFO
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${product.price}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      if (!isHamperMode)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onAddToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Add to Cart",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}