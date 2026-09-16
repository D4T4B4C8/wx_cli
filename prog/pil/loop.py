from PIL import Image
i = Image.open('t9.png')
w, h = i.size
size = min(w, h)
black = 0,0,0
red = 255,0,0
green = 0,255,0
blue = 0,0,255
for x in range(size):
    for y in range(0, size, 2):
        i.putpixel((y,x), black)
for x in range(size):
    for y in range(1, size, 2):
        i.putpixel((y,x), red)
i.save('o2.png')
