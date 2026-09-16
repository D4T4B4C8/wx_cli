import numpy as np
from PIL import Image

message = "hello"
image = Image.open('i.png', 'r')
width, height = image.size
img_arr = np.array(list(image.getdata()))

if image.mode == "P":
    print("not supported")
    exit()

cha = 4 if image.mode == "RGBA" else 3
pixels = img_arr.size // cha

stop_indicator = "$NEURAL$"
stop_indicator_length = len(stop_indicator)
message += stop_indicator

byte = ''.join(f"{ord(c):08b}" for c in message)
bits = len(byte)

if bits > pixels:
    print("full")
else:
    index = 0
    for i in range(pixels):
        for j in range(0, 3):
            if index < bits:
                img_arr[i][j] = int(bin(img_arr[i][j])[2:-1] + byte[index], 2)
                index += 1

img_arr = img_arr.reshape((height, width, cha))
r = Image.fromarray(img_arr.astype('uint8'), image.mode)
r.save('new.png')
