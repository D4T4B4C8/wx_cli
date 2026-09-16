from PIL import Image
image = Image.open('t9.png')
g8 = image.convert('L')
g8.show()
