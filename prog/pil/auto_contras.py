from PIL import Image, ImageOps
image = Image.open('t9.png')
c = ImageOps.autocontrast(image=image, cutoff=20)
c.show()
