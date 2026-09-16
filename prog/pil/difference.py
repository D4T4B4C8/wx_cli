from PIL import Image, ImageChops
a = Image.open('t9.png')
b = Image.open('t9.png')
id_ = ImageChops.difference(a, b)
id_.show()
