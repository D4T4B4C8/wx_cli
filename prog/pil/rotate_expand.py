from PIL import Image
image = Image.open('t9.png')
i_r = image.rotate(60, expand=True)
i_r.show()
