from PIL import Image
i = Image.open('1.png')
w, h = i.size
#[w,h ARE CALCULATED AUTOMATICALLY FROM THE IMAGE]
red = 10
green = -15
blue = 20
#[SHIFT AMOUNTS - CHANGE THE SIGN AS NEEDED, e.g. red = -10]
#[[0]=RED [1]=GREEN [2]=BLUE WHEN YOU READ A PIXEL AS A LIST]
for x in range(w):
    for y in range(h):
        pixelget = list(i.getpixel((x,y)))
        pixelget[0] = max(0, min(255, pixelget[0] + red))
        pixelget[1] = max(0, min(255, pixelget[1] + green))
        pixelget[2] = max(0, min(255, pixelget[2] + blue))
        i.putpixel((x,y), tuple(pixelget))
i.save('out.png')
#[SAVES THE SHIFTED IMAGE AS out.png]
