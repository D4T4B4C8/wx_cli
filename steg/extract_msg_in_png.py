import numpy as np
from PIL import Image

image = Image.open('new.png', 'r')
img = np.array(list(image.getdata()))
cha = 4 if image.mode == "RGBA" else 3
p = img.size // cha

sb = [bin(img[i][j])[-1] for i in range(p) for j in range(0, 3)]
sb = ''.join(sb)
sb = [sb[i:i+8] for i in range(0, len(sb), 8)]
sm = [chr(int(sb[i], 2)) for i in range(len(sb))]
sm = ''.join(sm)

si = "$NEURAL$"
if si in sm:
    print(sm[:sm.index(si)])
else:
    print("not found")
