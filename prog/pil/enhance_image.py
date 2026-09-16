from PIL import Image
image = Image.open('t9.png')
scale_factor = 2
i = (image.size[0] * scale_factor, image.size[1] * scale_factor)
better = image.resize(i)
better.save('new.png')
