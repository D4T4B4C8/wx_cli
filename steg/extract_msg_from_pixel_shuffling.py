import numpy as np
from PIL import Image
i = Image.open('out.png').convert('RGB')
seed = 42
shuffled = np.array(i.getdata())#[GETTING THE SHUFFLED PIXELS INTO A NUMPY ARRAY]
npix = len(shuffled)
np.random.seed(seed)
ind = np.random.permutation(npix)#[THIS PROCESS UNSHUFFLES THE PIXELS]
unshuffle = np.zeros(npix, np.uint32)
unshuffle[ind] = np.arange(npix)
unshuffle_pix = shuffled[unshuffle].astype(np.uint8)
r = Image.fromarray(unshuffle_pix.reshape(i.height, i.width, 3))
r.save('recover.png')
