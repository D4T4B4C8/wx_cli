from PIL import Image
image = Image.open('t9.png')
g1 = image.convert('1')
g1.show()
