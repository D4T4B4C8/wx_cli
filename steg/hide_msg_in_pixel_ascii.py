from PIL import Image
i = Image.open('t9.png').convert('RGBA')
w, h = i.size
xH = 255,72,0,1
xE = 255,69,0,1
xL = 255,76,0,1
xO = 255,79,0,1
#[H,E,L,L,O -> ASCII 72,69,76,76,79 -> ENCODED IN THE GREEN CHANNEL OF EACH PIXEL]
#[EACH LINE BELOW WRITES ONE LETTER AT A DIFFERENT (x,y) LOCATION]
i.putpixel((0,0), xH)
i.putpixel((0,1), xE)
i.putpixel((0,2), xL)
i.putpixel((0,3), xL)
i.putpixel((0,4), xO)
i.save('out.png')
