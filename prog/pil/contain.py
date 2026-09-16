from PIL import Image, ImageOps
image = Image.open('t9.png')
ic = ImageOps.contain(image=image, size=(500,200))
ic.show()
