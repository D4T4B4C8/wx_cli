from pylab import imshow, show, get_cmap
from numpy import random
Z = random.random((512,512))
imshow(Z, cmap=get_cmap("Spectral"), interpolation='nearest')
show()
