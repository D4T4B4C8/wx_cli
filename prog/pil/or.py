from PIL import Image, ImageChops
a = Image.open('t9.png')
b = Image.open('t9.png')
or_ = ImageChops.logical_or(a.convert('1'), b.convert('1'))
or_.show()
