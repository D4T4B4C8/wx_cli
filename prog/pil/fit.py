from PIL import Image, ImageOps
image = Image.open('t9.png')
if_ = ImageOps.fit(image=image, size=(300,300))
if_.show()
