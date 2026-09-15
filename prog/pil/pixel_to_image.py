from PIL import Image
with open('pix.txt', 'r') as file:
    r = file.readlines()
#[OPENS THE FILE, THEN READS EVERY LINE INTO A LIST]
#[FIRST CONVERT THE PIXEL DATA INTO A LIST OF TUPLES, OUTPUT LOOKS LIKE (255,0,0),(0,0,0) ETC.]
P = [tuple(map(int, line.strip().split())) for line in r]
W = 928
H = 1128
#[THE ORIGINAL WIDTH AND HEIGHT ARE IMPORTANT TO RECREATE THE IMAGE]
I = Image.new("RGB", (H, W))
#[CREATES A BLANK IMAGE AT THE ORIGINAL SIZE]
I.putdata(P)
#[WRITES ALL THE PIXELS BACK INTO THE NEW IMAGE]
FLIP = I.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
#[USED TO FLIP THE IMAGE]
ROTATE = FLIP.transpose(Image.Transpose.ROTATE_270)
#[USED TO ROTATE THE IMAGE]
ROTATE.save("final.png")
