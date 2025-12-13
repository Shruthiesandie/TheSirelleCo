import os
import json

BASE_DIR = "assets/images/all_categories"
OUTPUT_FILE = "assets/data/products.json"
PRICE = 999

IMAGE_EXTS = (".png", ".jpg", ".jpeg", ".webp")

products = []

for category in sorted(os.listdir(BASE_DIR)):
    category_path = os.path.join(BASE_DIR, category)
    if not os.path.isdir(category_path):
        continue

    for product in sorted(os.listdir(category_path)):
        product_path = os.path.join(category_path, product)
        if not os.path.isdir(product_path):
            continue

        # main image = first image in product folder
        main_image = None
        for file in sorted(os.listdir(product_path)):
            if file.lower().endswith(IMAGE_EXTS):
                main_image = f"{BASE_DIR}/{category}/{product}/{file}"
                break

        if not main_image:
            print(f"⚠️ Skipping {category}/{product} (no main image)")
            continue

        # collect extra images from subfolders
        extra_images = []
        for root, _, files in os.walk(product_path):
            if root == product_path:
                continue
            for f in sorted(files):
                if f.lower().endswith(IMAGE_EXTS):
                    rel_path = os.path.join(root, f).replace("\\", "/")
                    extra_images.append(rel_path)

        product_data = {
            "id": f"{category}_{product}",
            "name": product.upper(),
            "category": category,
            "price": PRICE,
            "mainImage": main_image.replace("\\", "/"),
            "images": extra_images,
            "description": f"{product} from {category}"
        }

        products.append(product_data)

# write JSON
os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
with open(OUTPUT_FILE, "w") as f:
    json.dump(products, f, indent=2)

print(f"✅ Generated {len(products)} products → {OUTPUT_FILE}")