import numpy as np
import matplotlib.pyplot as plt
import sounddevice
import os
import path

ROOT = os.getcwd()

filename = (ROOT + "/ps/sample_data/new_sample_data.txt")
mic = 30
fs = 15625
data = np.loadtxt(open(filename, 'rb').readlines()[:-1], delimiter=',')

sound_scaled = data[:, mic]/np.max(np.abs(data[:, mic]))
sound = data[:, mic]

sounddevice.play(sound_scaled, fs, blocking=True)
