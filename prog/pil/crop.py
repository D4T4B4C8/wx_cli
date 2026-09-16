from PIL import Image
image = Image.open('t9.png')
ic = image.crop((500,600,1500,1150))
ic.show()
