from PIL import Image, ImageOps
image = Image.open('t9.png').convert('RGB')
iv = ImageOps.invert(image)
iv.show()
