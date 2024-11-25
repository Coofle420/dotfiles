from PIL import Image, ImageDraw
import numpy as np

# Create a new image with transparency
width = 1920
height = 1080
image = Image.new('RGBA', (width, height), (0, 0, 0, 0))
draw = ImageDraw.Draw(image)

# Create gradient colors
def create_gradient(y, height):
    # Top color (dark purple)
    color1 = np.array([106, 76, 147, 80])  # #6a4c93 with 80 alpha
    # Bottom color (dark blue)
    color2 = np.array([26, 27, 38, 80])    # #1a1b26 with 80 alpha
    
    ratio = y / height
    return tuple(map(int, color1 * (1 - ratio) + color2 * ratio))

# Draw the gradient
for y in range(height):
    color = create_gradient(y, height)
    draw.line([(0, y), (width, y)], fill=color)

# Add some cyberpunk-style grid lines
grid_color = (122, 162, 247, 40)  # #7aa2f7 with 40 alpha
spacing = 50
for x in range(0, width, spacing):
    draw.line([(x, 0), (x, height)], fill=grid_color, width=1)
for y in range(0, height, spacing):
    draw.line([(0, y), (width, y)], fill=grid_color, width=1)

# Save the image
image.save('/home/demitri/.config/rofi/background.png')
