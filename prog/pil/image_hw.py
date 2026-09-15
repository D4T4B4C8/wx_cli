from PIL import Image
from numpy import array
image = Image.open('t9.png')
print(array(image).shape)
