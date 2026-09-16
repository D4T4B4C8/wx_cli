from PIL import Image, ImageFilter
image = Image.open('t9.png')
i_unsharp = image.filter(ImageFilter.UnsharpMask(radius=4))
i_unsharp.show()
