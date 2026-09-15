from PIL import Image, ImageFilter
image = Image.open('t9.png')
image_gaussblur = image.filter(ImageFilter.GaussianBlur(radius=4))
image_gaussblur.show()
