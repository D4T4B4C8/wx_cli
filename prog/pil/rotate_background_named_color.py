from PIL import Image, ImageColor
image = Image.open('t9.png')
ir = image.rotate(60, expand=True, fillcolor=ImageColor.getcolor('red','RGB'))
ir.show()
