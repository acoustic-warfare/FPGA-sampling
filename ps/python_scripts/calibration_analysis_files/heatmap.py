import numpy as np
import matplotlib.pyplot as plt
import sounddevice
import os
import math
from pathlib import Path
from ctypes import Structure, c_byte, c_int32, sizeof

import numpy as np
import matplotlib.pyplot as plt
import sounddevice
import os
import math
from pathlib import Path
from ctypes import Structure, c_byte, c_int32, sizeof
from scipy import signal 



fs=48828

print("Enter file: ")
fileChooser = input()

ROOT = os.getcwd()
path = Path(ROOT + "/"+fileChooser)

data = np.fromfile(path,dtype=c_int32,count=-1,offset=0) #Read the whole file
data2D = data.reshape(-1,68)  # reshapes into a Numpy array which is N*68 in dimensions

print("Enter microphone number: ")
mic = input()


data2D = data2D[:,4:]    # removes headerinformation

ref_mic=data2D[:,int(mic)]

sound_scaled = data2D[:, int(mic)]/np.max(np.abs(data2D[:, int(mic)])) # normalize mic data

 # Compute spectrogram
f, t, Sxx = signal.spectrogram(ref_mic, fs=fs)
#Plot heatmap
fig, ax = plt.subplots()
im = ax.pcolormesh(t, f, 10 * np.log10(Sxx), cmap='inferno', shading='auto')
ax.set_xlabel('Time (s)')
ax.set_ylabel('Frequency (Hz)')
cbar = fig.colorbar(im)
cbar.set_label('Power (dB)')
plt.show()
