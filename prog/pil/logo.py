from PIL import Image
a = Image.open('t9.png')
logo = Image.open('t9.png')
a.paste(logo, (0,0), mask=logo)
a.show()
