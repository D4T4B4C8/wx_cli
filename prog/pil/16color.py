from PIL import Image
image = Image.open('t9.png')
p16 = image.convert('P', palette=Image.Palette.ADAPTIVE, colors=16)
p16.show()
