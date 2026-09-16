from PIL import Image, ImageOps
image = Image.open('t9.png')
if_ = ImageOps.flip(image)
if_.show()
