from PIL import Image
image = Image.open('t9.png')
ir = image.rotate(60, expand=True, fillcolor=(255,255,255))
ir.show()
