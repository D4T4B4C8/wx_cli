from PIL import Image, ImageOps
image = Image.open('t9.png')
ib = ImageOps.expand(image=image, border=100)
ib.show()
