from PIL import Image, ImageOps
image = Image.open('t9.png')
image_crop = ImageOps.crop(image=image, border=400)
image_crop.show()
