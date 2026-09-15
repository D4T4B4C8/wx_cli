from PIL import Image
image = Image.open('t9.png')
p = image.convert('P')
p.show()
