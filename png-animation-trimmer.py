from PIL import Image
import os

input_dir = "./assets/sprites/objects/animated-oil/original"
output_dir = "./assets/sprites/objects/animated-oil/original/modified"

os.makedirs(output_dir, exist_ok=True)

# Padding (in pixels) to add around the largest bounding box
padding = 20

# Step 1: Determine the largest bounding box
largest_bbox = [float("inf"), float("inf"), 0, 0]  # [left, top, right, bottom]

for filename in os.listdir(input_dir):
    if filename.endswith(".png"):
        img_path = os.path.join(input_dir, filename)
        img = Image.open(img_path)

        # Get the bounding box (non-transparent area)
        bbox = img.getbbox()
        if bbox:
            largest_bbox[0] = min(largest_bbox[0], bbox[0])
            largest_bbox[1] = min(largest_bbox[1], bbox[1])
            largest_bbox[2] = max(largest_bbox[2], bbox[2])
            largest_bbox[3] = max(largest_bbox[3], bbox[3])

# Add padding to the bounding box
largest_bbox = [
    largest_bbox[0] - padding,
    largest_bbox[1] - padding,
    largest_bbox[2] + padding,
    largest_bbox[3] + padding,
]

print(f"Largest bounding box with padding: {largest_bbox}")

# Step 2: Crop all images to the consistent bounding box
for filename in os.listdir(input_dir):
    if filename.endswith(".png"):
        img_path = os.path.join(input_dir, filename)
        img = Image.open(img_path)

        # Ensure the bounding box stays within the image dimensions
        crop_box = (
            max(0, largest_bbox[0]),
            max(0, largest_bbox[1]),
            min(img.width, largest_bbox[2]),
            min(img.height, largest_bbox[3]),
        )

        # Crop the image to the calculated region
        cropped_img = img.crop(crop_box)

        # Create a new canvas to maintain alignment
        final_canvas = Image.new("RGBA", (crop_box[2] - crop_box[0], crop_box[3] - crop_box[1]), (0, 0, 0, 0))
        final_canvas.paste(cropped_img, (0, 0))

        # Save the cropped image
        final_canvas.save(os.path.join(output_dir, filename))

print(f"Cropped images saved in '{output_dir}'.")

