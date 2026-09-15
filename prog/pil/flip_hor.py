from PIL import Image
image = Image.open('t9.png')
ifh = image.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
ifh.show()
