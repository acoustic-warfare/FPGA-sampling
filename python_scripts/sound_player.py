import numpy as np
import sounddevice
import os
from pathlib import Path
from ctypes import c_int32


def Average(l):
    return sum(l) / len(l)


print("Enter file: ")
fileChooser = input()

ROOT = os.getcwd()
path = Path(ROOT + "/recorded_data/" + fileChooser + ".bin")

data = np.fromfile(path, dtype=c_int32, count=-1, offset=0)

nr_arrays = 1  # todo: make this find the nr_arrays from the header :)
subbands_32_mode_on = 1
subband_to_listen = 0

expected_columns = nr_arrays * 64 + 4
data2D = data.reshape(-1, expected_columns)

print("Enter microphone number (y for all mics): ")
mic = input()

fs = 48828.125
if subbands_32_mode_on == 1:
    fs = fs / 32

subband_nr = data2D[:, 3]  # Extract subband numbers

data2D = data2D[subband_nr == subband_to_listen]  # Filter rows for the selected subband

data2D = data2D[:, 4:]  # Remove header information

if data2D.size == 0:
    print("No data found for the selected subband.")
else:
    if mic.lower() == "y":
        for i in range(0, min(256, data2D.shape[1])):
            mic_data = data2D[:, i]
            sound_scaled = mic_data / np.max(np.abs(mic_data))
            print(i)
            sounddevice.play(sound_scaled, fs, blocking=True)
    else:
        mic_index = int(mic)
        if mic_index >= data2D.shape[1]:
            print("Invalid microphone index.")
        else:
            mic_data = data2D[:, mic_index]
            sound_scaled = mic_data / np.max(np.abs(mic_data))

            print(np.max(np.abs(mic_data)))
            print(sound_scaled.shape)
            print(sound_scaled.dtype)

            sounddevice.play(sound_scaled, fs, blocking=True)
