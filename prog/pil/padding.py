from PIL import Image, ImageOps
image = Image.open('t9.png')
ip = ImageOps.pad(image=image, size=(2500,1600))
ip.show()
