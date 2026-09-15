from PIL import Image
i = Image.open('t9.png')
w, h = i.size
red = 255,0,0
green = 0,255,0
blue = 0,0,255
x = 0
y = 0
#[x,y = LOCATION OF THE RED PIXEL]
f = 0
a = 1
#[f,a = LOCATION OF THE GREEN PIXEL]
z = 0
n = 2
#[z,n = LOCATION OF THE BLUE PIXEL]
i.putpixel((x,y), red)
i.putpixel((f,a), green)
i.putpixel((z,n), blue)
i.save('o2.png')
