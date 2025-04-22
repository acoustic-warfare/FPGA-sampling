import numpy as np
import os
from pathlib import Path
import matplotlib.pyplot as plt


def load_data_FPGA(fileChooser):
    ROOT = os.getcwd()
    path = Path(ROOT + "/recorded_data/" + fileChooser + ".bin")
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 259)  # Each row: 4 header fields + 64 mic data values
    subband_info = data2D[:, 2] >> 24  # Extract subband column
    mic_data = data2D[:, 3:]  # Microphone data starts from column 5 (index 4)
    sample_counter = data2D[:, 2].astype(np.uint32) & 0x00FFFFFF
    sample_counter = (sample_counter - sample_counter[0])/63
    sample_counter = sample_counter.astype(int)

    f_sampling = 48828.125  # Hz
    return mic_data, sample_counter, subband_info, f_sampling


# Main execution block
print("Enter a file to plot: ")
# fileChooser = input()
fileChooser = "recive_and_plot"
mic_nr = 1  # (0 - 63) Selecting microphone number 35

# Load data
mic_data, sample_counter, subband_info, f_sampling = load_data_FPGA(fileChooser)

mic_data = mic_data[:, :128]
mic_data_real = mic_data[:, 0::2]  # even indices: 0, 2, 4, ...
mic_data_imag = mic_data[:, 1::2]  # odd indices: 1, 3, 5, ...
mic_data_real = mic_data_real.astype(np.float32)
mic_data_imag = mic_data_imag.astype(np.float32)

mic_data_power = mic_data_real**2 + mic_data_imag**2

mic_data_power_mic = mic_data_power[:, mic_nr]


unique_samples, inverse_indices = np.unique(sample_counter, return_inverse=True)
num_samples = len(unique_samples)
result_array = np.zeros((num_samples, 64))  # 64 subbands

# Fill in the result_array
for i in range(len(mic_data_power_mic)):
    row = inverse_indices[i]                # maps to 0..num_samples-1
    col = subband_info[i]                   # 0..63
    result_array[row, col] = mic_data_power_mic[i]


def db(x):
    return 20 * np.log10(x)


plt.imshow(db(result_array), cmap='viridis', aspect='auto')
plt.colorbar()
plt.xlabel("Channel")
plt.ylabel("Time")
plt.show()
