import numpy as np
import matplotlib.pyplot as plt
import sounddevice
filename= '/home/ljudkriget/Projects/Ljud_Kriget/ps/nanana.txt'
mic = 1
fs = 15625
data = np.loadtxt(open(filename,'rb'), delimiter=',')
print(np.shape(data))
print(data)

scaled_data = data/np.max(np.abs(data[:,mic]))
sounddevice.play(scaled_data, fs, blocking=True)


