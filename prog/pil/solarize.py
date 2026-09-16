from PIL import Image, ImageOps
image = Image.open('t9.png')
is_ = ImageOps.solarize(image=image, threshold=100)
is_.show()
