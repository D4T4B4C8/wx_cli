from PIL import Image, ImageOps
image = Image.open('t9.png')
ig = ImageOps.grayscale(image=image)
ig.show()
