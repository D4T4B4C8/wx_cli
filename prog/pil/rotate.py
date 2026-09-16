from PIL import Image
image = Image.open('t9.png')
image_rotate = image.rotate(60)
image_rotate.show()
