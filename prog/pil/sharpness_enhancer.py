from PIL import Image, ImageEnhance
image = Image.open('t9.png')
s_e = ImageEnhance.Sharpness(image)
e_i = s_e.enhance(2)
e_i.show()
