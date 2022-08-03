import numpy as np
import matplotlib.pyplot as plt
import sounddevice
import os

ROOT = os.getcwd()

filename = (ROOT + "/mic_data/new_sample_data.txt")
mic = 8
fs = 16400
data = np.loadtxt(open(filename, 'rb').readlines()[:-1], delimiter=',')

sound_scaled = data[:, mic]/np.max(np.abs(data[:, mic]))

sounddevice.play(sound_scaled, fs, blocking=True)
