import os
import json

BASE = "assets/images/all_categories"
OUTPUT = "assets/data/products.json"

products = []

def is_image(file):
    return file.lower().endswith((".png", ".jpg", ".jpeg", ".webp"))

for category in os.listdir(BASE):
    category_path = os.path.join(BASE, category)
    if not os.path.isdir(category_path):
        continue

    for product in os.listdir(category_path):
        product_path = os.path.join(category_path, product)
        if not os.path.isdir(product_path):
            continue

        cover_image = None
        gallery_images = []

        # main / cover image
        for file in os.listdir(product_path):
            if is_image(file):
                cover_image = f"{BASE}/{category}/{product}/{file}"
                break

        # extra images folder (bdiff1)
        diff_folder = os.path.join(product_path, "bdiff1")
        if os.path.exists(diff_folder):
            for img in os.listdir(diff_folder):
                if is_image(img):
                    gallery_images.append(
                        f"{BASE}/{category}/{product}/bdiff1/{img}"
                    )

        if cover_image:
            products.append({
                "id": f"{category}_{product}",
                "name": product.replace("_", " ").title(),
                "category": category,
                "price": 999,
                "mainImage": cover_image,
                "images": gallery_images,
                "description": f"{product} from {category}"
            })

os.makedirs("assets/data", exist_ok=True)
with open(OUTPUT, "w") as f:
    json.dump(products, f, indent=2)

print(f"✅ Generated {len(products)} products")