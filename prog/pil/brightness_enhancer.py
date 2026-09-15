from PIL import Image, ImageEnhance
image = Image.open('t9.png')
b_e = ImageEnhance.Brightness(image)
e_i = b_e.enhance(2)
e_i.show()
