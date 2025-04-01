import numpy as np
import os
from pathlib import Path
import matplotlib.pyplot as plt


def load_data_FPGA(fileChooser):
    ROOT = os.getcwd()
    path = Path(ROOT + "/recorded_data/" + fileChooser + ".bin")
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 68)  # Each row: 4 header fields + 64 mic data values
    mic_nr = data2D[:, 3]  # Extract subband column (4th column, index 3)
    mic_data = data2D[:, 4:]  # Microphone data starts from column 5 (index 4)
    sample_counter = data2D[:, 2]
    sample_counter = (sample_counter - sample_counter[0])/32
    sample_counter = sample_counter.astype(int)

    f_sampling = 48828.125  # Hz
    return mic_data, sample_counter, mic_nr, f_sampling


def split_to_subbands_for_mic(all_mic_data, sample_counter, mic_nr, select_mic):
    mic_data = []

    for i in range(len(sample_counter)):
        if mic_nr[i] == select_mic:
            mic_data.append(all_mic_data[i])

    return mic_data


# Main execution block
print("Enter a file to plot: ")
# fileChooser = input()
fileChooser = "recive_and_plot"
select_mic = 63  # (0 - 63) Selecting microphone number 35

# Load data
all_mic_data, sample_counter, mic_nr, f_sampling = load_data_FPGA(fileChooser)

# print(all_mic_data[0])

mic_data = split_to_subbands_for_mic(all_mic_data, sample_counter, mic_nr, select_mic)
mic_data_c = []
for a in range(len(mic_data)):
    complex_sample = []
    for b in range(int(len(mic_data[0]) / 2)):
        complex_sample.append(complex(mic_data[a][b * 2], mic_data[a][b * 2 + 1]))
    mic_data_c.append(complex_sample)

print(len(all_mic_data))
print(len(mic_data))


print(mic_data[0])
print(mic_data_c[0])


def db(x):
    return 20 * np.log10(x + 1e-10)


plt.figure(figsize=(10, 5))

for i in range(10):
    plt.plot(db(np.abs(mic_data_c[i])),  marker='o')


plt.xlabel('Frequency Bin')
plt.ylabel('Magnitude (dB)')
plt.title('FFT Magnitude Response Comparison')
plt.grid()
plt.show()
