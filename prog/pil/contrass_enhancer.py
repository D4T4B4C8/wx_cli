from PIL import Image, ImageEnhance
image = Image.open('t9.png')
c_e = ImageEnhance.Contrast(image)
e_i = c_e.enhance(2)
e_i.show()
