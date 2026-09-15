from PIL import Image, ImageChops
a = Image.open('t9.png')
b = Image.open('t9.png')
im_ = ImageChops.add_modulo(a, b)
im_.show()
