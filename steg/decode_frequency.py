from scipy.io import wavfile
import numpy as np

fs, x = wavfile.read("final.wav")
if x.ndim > 1:
    x = x[:,0]

chunk = int(0.5 * fs)

for i in range(0, len(x), chunk):
    s = x[i:i+chunk]
    f = np.fft.rfftfreq(len(s), 1/fs)
    F = np.abs(np.fft.rfft(s))
    print(round(f[np.argmax(F)]))
