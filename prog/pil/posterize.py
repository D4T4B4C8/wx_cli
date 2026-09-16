from PIL import Image, ImageOps
image = Image.open('t9.png')
ip = ImageOps.posterize(image=image, bits=1)
ip.show()
