from PIL import Image
image = Image.open('t9.png')
ifv = image.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
ifv.show()
