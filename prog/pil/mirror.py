from PIL import Image, ImageOps
image = Image.open('t9.png')
im = ImageOps.mirror(image)
im.show()
