import numpy as np
from PIL import Image
i = Image.open('t9.png').convert('RGB')
seed = 42
pix = np.array(i.getdata()) #[GET THE PIXELS AND PUT THEM IN A NUMPY ARRAY]
np.random.seed(seed) #[GENERATE A RANDOM PERMUTATION FROM THE SEED]
ind = np.random.permutation(len(pix))
shuffled = pix[ind].astype(np.uint8) #[USED TO SHUFFLE THE IMAGE]
r = Image.fromarray(shuffled.reshape(i.height, i.width, 3)) #[USED TO RECREATE THE IMAGE ]
r.save('out.png')
