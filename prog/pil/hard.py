from PIL import Image, ImageChops
a = Image.open('t9.png')
b = Image.open('t9.png')
ihl = ImageChops.hard_light(a, b)
ihl.show()
