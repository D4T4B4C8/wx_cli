from PIL import Image
i = Image.open('t9.png')
R = i.resize((200, 325))
R.save('o.png')
