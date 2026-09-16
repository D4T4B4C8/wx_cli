from PIL import Image, ImageOps
image = Image.open('t9.png')
is_ = ImageOps.scale(image=image, factor=0.4)
is_.show()
