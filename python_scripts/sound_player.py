import numpy as np
import matplotlib.pyplot as plt
import sounddevice
import os
import math
from pathlib import Path
from ctypes import Structure, c_byte, c_int32, sizeof

def Average(l): 
    avg = sum(l) / len(l) 
    return avg


print("Enter file: ")
fileChooser = input()

ROOT = os.getcwd()
path = Path(ROOT + "/"+fileChooser)

data = np.fromfile(path,dtype=c_int32,count=-1,offset=0) #Read the whole file
data2D = data.reshape(-1,76)  # reshapes into a Numpy array which is N*68 in dimensions

print("Enter microphone number: ")
mic = input()



#fs = np.fromfile(path,dtype=c_int32,count=1,offset=8) # get sampling frequency from the file
#if(fs == 0): #Default to 48828 if no fs is sent in the data
#    fs = 48828 
fs = 48828 

data2D = data2D[:,2:]    # removes headerinformation

mic_data=data2D[:,int(mic)]

sound_scaled = data2D[:, int(mic)]/np.max(np.abs(data2D[:, int(mic)])) # normalize mic data
#sound_scaled = data2D[:, int(mic)]/(500000)
#sound_scaled = data2D[:, int(mic)]
print(np.max(np.abs(data2D[:, int(mic)])))

print(sound_scaled.shape)
print(sound_scaled.dtype)
sounddevice.play(sound_scaled, fs, blocking=True)
