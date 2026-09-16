from PIL import Image
a = Image.open('t9.png')
b = Image.open('t9.png')
m = Image.composite(a, b, Image.new('L', a.size, 100))
m.show()
