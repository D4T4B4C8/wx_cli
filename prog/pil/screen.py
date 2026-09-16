from PIL import Image, ImageChops
a = Image.open('t9.png')
b = Image.open('t9.png')
is_ = ImageChops.screen(a, b)
is_.show()
