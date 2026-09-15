from PIL import Image, ImageChops
a = Image.open('t9.png')
b = Image.open('t9.png')
isl = ImageChops.soft_light(a, b)
isl.show()
