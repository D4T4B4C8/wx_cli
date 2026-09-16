from PIL import Image
import numpy
Z = numpy.random.rand(512,512,3)*255
#[512 IS IMAGE SIZE YOU CAN CHANGE IF YOU WANT]
i = Image.fromarray(Z.astype('uint8')).convert('RGBA')
i.save('KEY.png')
