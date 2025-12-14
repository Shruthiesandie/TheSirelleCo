import os

BASE_PATH = "assets/images"
OUTPUT_FILE = "lib/data/product_data.dart"

IMAGE_EXTENSIONS = (".jpg", ".jpeg", ".png", ".webp")

products = []

for category in sorted(os.listdir(BASE_PATH)):
    category_path = os.path.join(BASE_PATH, category)
    if not os.path.isdir(category_path):
        continue

    for folder in sorted(os.listdir(category_path)):
        product_path = os.path.join(category_path, folder)
        if not os.path.isdir(product_path):
            continue

        thumbnail = f"assets/images/{category}/{folder}/bottle.jpg"
        images = [thumbnail]

        # Add images from bdiff1 (skip bottle.jpg)
        diff_folder = os.path.join(product_path, "bdiff1")
        if os.path.exists(diff_folder):
            for img in sorted(os.listdir(diff_folder)):
                if img.lower() == "bottle.jpg":
                    continue
                if img.lower().endswith(IMAGE_EXTENSIONS):
                    images.append(
                        f"assets/images/{category}/{folder}/bdiff1/{img}"
                    )

        product = f"""
  Product(
    id: '{folder}',
    name: '{folder.upper()}',
    category: '{category.replace("_", " ").capitalize()}',
    price: 899,
    thumbnail: '{thumbnail}',
    images: {images},
  ),
"""
        products.append(product)

dart_file = f"""import '../models/product.dart';

final List<Product> allProducts = [
{''.join(products)}
];
"""

with open(OUTPUT_FILE, "w") as f:
    f.write(dart_file)

print("✅ product_data.dart generated correctly with gallery images")