from PIL import Image, ImageFilter
image = Image.open('t9.png')
max_img = image.filter(ImageFilter.MaxFilter(size=5))
max_img.show()
