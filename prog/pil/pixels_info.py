from PIL import Image
image = Image.open('t9.png')
print(image.mode)
print(image.getbands())
[THIS BOTH TELL YOU WHETHER THE IMAGE IS 'RGB' OR NOT]
print(image.info)
