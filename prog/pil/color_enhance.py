from PIL import Image, ImageEnhance
image = Image.open('t9.png')
c_e = ImageEnhance.Color(image)
enhanced_image = c_e.enhance(2)
enhanced_image.show()
