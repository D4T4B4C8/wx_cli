from PIL import Image
a = Image.open('t9.png')
b = Image.open('t9.png')
m = Image.blend(a, b, 0.5)
m.show()
