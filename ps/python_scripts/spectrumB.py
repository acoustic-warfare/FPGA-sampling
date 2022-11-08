import matplotlib.pyplot as plt
import numpy as np
import matplotlib.pyplot as plt
import sounddevice
import os
import math
from pathlib import Path
from ctypes import Structure, c_byte, c_int32, sizeof
from scipy import signal


print("Enter file: ")
fileChooser = input()

ROOT = os.getcwd()
path = Path(ROOT + "/"+fileChooser)

data = np.fromfile(path,dtype=c_int32,count=-1,offset=0) #Read the whole file
data2D = data.reshape(-1,68)  # reshapes into a Numpy array which is N*68 in dimensions
data2D = data2D[:,4:]    # take out mic data
fs = np.fromfile(path,dtype=c_int32,count=1,offset=8) # get sampling frequency from the file



singel_mic_data = data2D[:,1]


f, t, Sxx = signal.spectrogram(data2D[:,45], fs, nfft=4028)
plt.pcolormesh(t, f, Sxx)
plt.ylabel('Frequency [Hz]')
plt.xlabel('Time [sec]')
plt.show()