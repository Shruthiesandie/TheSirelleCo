import os

ASSETS_ROOT = "assets/images"

def generate_products():
    products = []

    # loop through all categories (bottles, candle, etc.)
    for category in sorted(os.listdir(ASSETS_ROOT)):
        category_path = os.path.join(ASSETS_ROOT, category)
        if not os.path.isdir(category_path):
            continue

        # loop through products inside each category
        for product_folder in sorted(os.listdir(category_path)):
            product_dir = os.path.join(category_path, product_folder)
            if not os.path.isdir(product_dir):
                continue

            # get all PNG images in the product folder
            images = sorted([
                f for f in os.listdir(product_dir)
                if f.lower().endswith(".png")
            ])

            if not images:
                continue

            # first image = thumbnail
            thumbnail = f"{ASSETS_ROOT}/{category}/{product_folder}/{images[0]}"

            # all images = swipe gallery
            image_paths = [
                f'"{ASSETS_ROOT}/{category}/{product_folder}/{img}"'
                for img in images
            ]

            product = f"""
  Product(
    id: "{product_folder}",
    name: "{category.capitalize()} {product_folder[1:]}",
    thumbnail: "{thumbnail}",
    images: [
      {",\n      ".join(image_paths)}
    ],
  ),
"""
            products.append(product)

    return products


# generate everything
all_products = generate_products()

print("final List<Product> products = [")
for p in all_products:
    print(p)
print("];")