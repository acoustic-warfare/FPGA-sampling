import numpy as np
import matplotlib.pyplot as plt
import sounddevice
filename= '/home/ljudkriget/Projects/Ljud_Kriget/data.txt'
fs = 48828.125
data = np.loadtxt(open(filename,'r'))
print(np.shape(data))
print(data)

scaled_data = data/np.max(np.abs(data))
sounddevice.play(scaled_data, fs, blocking=True)

