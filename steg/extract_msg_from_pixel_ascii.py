from PIL import Image
i = Image.open("out.png").convert('RGB')
a = ''
#[a WILL COLLECT THE EXTRACTED CHARACTERS]
W, H = i.size
#[READ THE SIZE DIRECTLY FROM THE IMAGE INSTEAD OF HARDCODING IT, SO THIS ALWAYS MATCHES out.png]
for x in range(W):
    for y in range(H):
        r,g,b = i.getpixel((x,y))
        if x == 0:
            a += chr(g)
print(a)
#[ONLY COLUMN x=0 WAS WRITTEN TO IN THE HIDING STEP, SO ONLY THAT COLUMN IS READ BACK]
