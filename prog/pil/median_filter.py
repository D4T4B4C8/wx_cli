from PIL import Image, ImageFilter
image = Image.open('t9.png')
median = image.filter(ImageFilter.MedianFilter(size=5))
median.show()
