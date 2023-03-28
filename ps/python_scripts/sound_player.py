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
data2D = data.reshape(-1,68)  # reshapes into a Numpy array which is N*68 in dimensions

print("Enter microphone number: ")
mic = input()



fs = np.fromfile(path,dtype=c_int32,count=1,offset=8) # get sampling frequency from the file
data2D = data2D[:,4:]    # removes headerinformation

mic_data=data2D[:,int(mic)]

sound_scaled = data2D[:, int(mic)]/np.max(np.abs(data2D[:, int(mic)])) # normalize mic data

samples = len(data2D[:,0])            # number of recorded samples
t_total = samples/fs                # total time of recording
t = np.linspace(0,t_total,samples)  # time vector
data_FFT = np.fft.fft(data2D[:,int(mic)])  # discrete FFT of data from one mic
nu = np.fft.fftfreq(t.shape[-1])    # normalized frequency nu



sounddevice.play(sound_scaled, fs, blocking=True)
