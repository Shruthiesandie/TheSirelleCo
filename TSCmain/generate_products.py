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

        # Find main image (thumbnail) from product root
        thumbnail = None
        for file in sorted(os.listdir(product_path)):
            file_path = os.path.join(product_path, file)
            if os.path.isfile(file_path) and file.lower().endswith(IMAGE_EXTENSIONS):
                thumbnail = f"assets/images/{category}/{folder}/{file}"
                break

        images = []

        # Collect gallery images from ALL subfolders (excluding thumbnail)
        thumb_name = os.path.basename(thumbnail) if thumbnail else None

        for sub in sorted(os.listdir(product_path)):
            sub_path = os.path.join(product_path, sub)
            if os.path.isdir(sub_path):
                for img in sorted(os.listdir(sub_path)):
                    if not img.lower().endswith(IMAGE_EXTENSIONS):
                        continue
                    if img == thumb_name:
                        continue
                    images.append(
                        f"assets/images/{category}/{folder}/{sub}/{img}"
                    )

        # If no gallery images found, use thumbnail as image
        if not images and thumbnail is not None:
            images.append(thumbnail)

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