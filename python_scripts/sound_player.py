import numpy as np
import sounddevice
import os
from pathlib import Path
from ctypes import c_int32


def Average(l):
    avg = sum(l) / len(l)
    return avg


print("Enter file: ")
fileChooser = input()
# fileChooser = "ljud"

ROOT = os.getcwd()
path = Path(ROOT + "/" + fileChooser)

data = np.fromfile(path, dtype=c_int32, count=-1, offset=0)  # Read the whole file
# reshapes into a Numpy array which is N*68 in dimensions

nr_arrays = 2  # todo: make this find the nr_arrays from the header :)
expected_columns = nr_arrays * 64 + 2
data2D = data.reshape(-1, expected_columns)

print("Enter microphone number (y for all mics): ")
mic = input()

fs = 48828
data2D = data2D[:, 2:]  # removes headerinformation

if mic.lower() == "y":
    for i in range(0, 256):
        mic_data = data2D[:, int(i)]
        # normalize mic data
        sound_scaled = data2D[:, int(i)] / np.max(np.abs(data2D[:, int(i)]))
        # sound_scaled = data2D[:, int(i)]/(2**24)
        print(i)
        sounddevice.play(sound_scaled, fs, blocking=True)
else:
    mic_data = data2D[:, int(mic)]
    # normalize mic data
    sound_scaled = data2D[:, int(mic)] / np.max(np.abs(data2D[:, int(mic)]))
    # sound_scaled = data2D[:, int(mic)]/(500000)

    print(np.max(np.abs(data2D[:, int(mic)])))
    print(sound_scaled.shape)
    print(sound_scaled.dtype)

    sounddevice.play(sound_scaled, fs, blocking=True)
