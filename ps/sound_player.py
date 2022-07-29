import numpy as np
import matplotlib.pyplot as plt
import sounddevice
filename= '/home/ljudkriget/Projects/Ljud_Kriget/ps/nanana.txt'
mic = 5
fs = 15625
data = np.loadtxt(open(filename,'rb').readlines()[:-1], delimiter=',')

#data = np.loadtxt(open(filename,'r'))
#scaled_data = data/np.max(np.abs(data))

sound_scaled = data[:,mic]/np.max(np.abs(data[:,mic]))
sound = data[:,mic]


sounddevice.play(sound_scaled, fs, blocking=True)
#sounddevice.play(sound, fs, blocking=True)



