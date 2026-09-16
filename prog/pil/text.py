from PIL import Image, ImageDraw, ImageFont
i = Image.open('t9.png')
draw = ImageDraw.Draw(i)
font = ImageFont.truetype('b.ttf', size=80)
draw.text((100,640), 'Hello lol', font=font, fill=(0,255,255))
i.show()
