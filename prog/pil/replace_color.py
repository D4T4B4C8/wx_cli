from PIL import Image
image = Image.open('t9.png')
for x in range(image.size[0]):
    for y in range(image.size[1]):
        if image.getpixel((x,y))[0] > 200:
            image.putpixel((x,y), (0,0,0))
[(0,0,0) = black]
image.show()
