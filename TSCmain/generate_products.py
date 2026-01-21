import os

ASSETS_ROOT = "assets/images"

def generate_products():
    products = []

    allowed_categories = {"boy_friend", "girl_friend"}

    # loop through all categories (bottles, candle, etc.)
    for category in sorted(os.listdir(ASSETS_ROOT)):
        if category not in allowed_categories:
            continue
        category_path = os.path.join(ASSETS_ROOT, category)
        if not os.path.isdir(category_path):
            continue

        # collect images directly inside the category folder
        images = sorted([
            f for f in os.listdir(category_path)
            if f.lower().endswith((".png", ".jpg", ".jpeg"))
        ])

        if not images:
            continue

        # create ONE product per image
        for idx, img in enumerate(images, start=1):
            image_path = f"{ASSETS_ROOT}/{category}/{img}"

            product = f"""
  Product(
    id: "{category}_{idx}",
    name: "{category.replace('_', ' ').title()} {idx}",
    thumbnail: "{image_path}",
    images: [
      "{image_path}"
    ],
  ),
"""
            products.append(product)

    return products


# generate everything
all_products = generate_products()

PRODUCTS_FILE = "lib/data/products.dart"

with open(PRODUCTS_FILE, "r") as f:
    content = f.read()

marker = "final List<Product> products = ["

if marker not in content:
    raise Exception("Products list marker not found in products.dart")

before, after = content.split(marker, 1)
existing, rest = after.split("];", 1)

new_products = "".join(all_products)

updated = (
    before
    + marker
    + existing.rstrip()
    + "\n"
    + new_products
    + "\n];"
    + rest
)

with open(PRODUCTS_FILE, "w") as f:
    f.write(updated)

print("✅ Boy Friend & Girl Friend products added automatically to products.dart")