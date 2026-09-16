from PIL import Image, ImageOps
image = Image.open('t9.png')
ie = ImageOps.equalize(image=image)
ie.show()
