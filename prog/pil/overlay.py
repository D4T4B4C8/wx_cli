from PIL import Image, ImageChops
a = Image.open('t9.png')
b = Image.open('t9.png')
io_ = ImageChops.overlay(a, b)
io_.show()
