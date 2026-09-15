from PIL import Image, ImageFilter
image = Image.open('t9.png')
image_boxblur = image.filter(ImageFilter.BoxBlur(radius=4))
image_boxblur.show()
