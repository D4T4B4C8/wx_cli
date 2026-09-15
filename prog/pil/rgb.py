from PIL import Image
i = Image.open('t9.png')
red = 255,0,0
green = 0,255,0
blue = 0,0,255
x = 0
y = 0
f = 1
a = 0
z = 2
n = 0
i.putpixel((x,y), red)
i.putpixel((f,a), green)
i.putpixel((z,n), blue)
i.save('o2.png')
