from PIL import Image, ImageChops
a = Image.open('t9.png')
b = Image.open('t9.png')
id_ = ImageChops.darker(a, b)
id_.show()
