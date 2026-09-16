from PIL import Image, ImageChops
a = Image.open('t9.png')
b = Image.open('t9.png')
add = ImageChops.logical_and(a.convert('1'), b.convert('1'))
add.show()
