import os
import json

BASE_DIR = "assets/images"
OUTPUT_FILE = "assets/data/products.json"

products = []

def norm(path):
    return path.replace("\\", "/")

for category in sorted(os.listdir(BASE_DIR)):
    category_path = os.path.join(BASE_DIR, category)
    if not os.path.isdir(category_path):
        continue

    for product in sorted(os.listdir(category_path)):
        product_path = os.path.join(category_path, product)
        if not os.path.isdir(product_path):
            continue

        images = []
        main_image = None

        for root, _, files in os.walk(product_path):
            for file in files:
                if file.lower().endswith((".jpg", ".jpeg", ".png", ".webp")):
                    full = norm(os.path.join(root, file))
                    if main_image is None:
                        main_image = full
                    else:
                        images.append(full)

        if not main_image:
            continue

        products.append({
            "id": f"{category}_{product}",
            "name": product.upper(),
            "category": category,
            "price": 999,
            "mainImage": main_image,
            "images": images,
            "description": f"{product} from {category}"
        })

os.makedirs("assets/data", exist_ok=True)

with open(OUTPUT_FILE, "w") as f:
    json.dump(products, f, indent=2)

print(f"✅ Generated {len(products)} products → {OUTPUT_FILE}")