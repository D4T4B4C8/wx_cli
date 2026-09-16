from PIL import Image, ImageOps
image = Image.open('t9.png')
ic = ImageOps.colorize(image=image.convert('L'), black='pink', white='red')
ic.show()
