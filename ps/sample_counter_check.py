import numpy as np
import matplotlib.pyplot as plt
import sounddevice
import os

ROOT = os.getcwd()

filename = (ROOT + "/ps/sample_data/new_sample_data.txt")
mic = 3
data = np.loadtxt(open(filename, 'rb').readlines()[:-1], delimiter=',')

#sound_scaled = data[:, mic]/np.max(np.abs(data[:, mic]))
count = data[:, mic]

print(len(count))

for i in range(1,len(count) - 2):
    one = (int(count[i])) - (int(count[i-1]))
    if(one != 1):
       print(i, ": ",(int(count[i])), " ", (int(count[i-1])))
