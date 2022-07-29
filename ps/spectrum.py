from scipy import signal
import matplotlib.pyplot as plt
import numpy as np

filename= '/home/ljudkriget/Projects/ljud_kriget/ps/delay_52_9k.txt'
fs = 19531.25
data = np.loadtxt(open(filename,'r'))

f, t, Sxx = signal.spectrogram(data, fs, nfft=4028)
plt.pcolormesh(t, f, Sxx)
plt.ylabel('Frequency [Hz]')
plt.xlabel('Time [sec]')
plt.show()