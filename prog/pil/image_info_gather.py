from PIL import Image
image = Image.open('t9.png')
print(image.size)
print(image.filename)
print(image.format)
print(image.format_description)
