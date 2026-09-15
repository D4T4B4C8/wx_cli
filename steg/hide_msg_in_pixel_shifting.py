#[NOW FLATTEN THAT IMAGE INTO A SINGLE ROW: WIDTH=65000, HEIGHT=1]
from PIL import Image
i = Image.open('o.png')
w, h = i.size
pix = [i.getpixel((x,y)) for y in range(h) for x in range(w)]
new = Image.new('RGB', (w*h, 1))
new.putdata(pix)
new.save('wh.jpg')
