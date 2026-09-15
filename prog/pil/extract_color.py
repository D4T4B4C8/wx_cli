from PIL import Image
image = Image.open('t9.png')
print(image.getcolors(maxcolors=image.size[0]*image.size[1]))
