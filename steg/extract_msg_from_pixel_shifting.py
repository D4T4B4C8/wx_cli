from PIL import Image
img = Image.open('wh.jpg').convert('RGB')
new = Image.new('RGB', (200, 326))
w = h = 0
for i in range(0, img.size[0]):
    r,g,b = img.getpixel((i,0))
    w = i % 200
    if i % 200 == 0:
        h = h + 1
    new.putpixel((w,h), (r,g,b))
new.save('unhide.jpg')
