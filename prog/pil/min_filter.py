from PIL import Image, ImageFilter
image = Image.open('t9.png')
min_img = image.filter(ImageFilter.MinFilter(size=5))
min_img.show()
