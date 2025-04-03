import numpy as np
import os
from pathlib import Path
import matplotlib.pyplot as plt
from scipy.signal import freqs


def load_data_FPGA(fileChooser):
    ROOT = os.getcwd()
    path = Path(ROOT + "/recorded_data/" + fileChooser + ".bin")
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 259)  # Each row: 4 header fields + 64 mic data values
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
select_mic = 0  # (0 - 63) Selecting microphone number 35

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

fft_result = mic_data_c[0]

# Compute magnitude
magnitude = np.abs(fft_result)

# Frequency bins
freqs = np.fft.fftfreq(len(fft_result)) * 48828.125

# Plot Magnitude Spectrum
plt.figure(figsize=(10, 5))
plt.stem(freqs, magnitude)
plt.xlabel("Normalized Frequency")
plt.ylabel("Magnitude")
plt.title("Magnitude Spectrum")
plt.grid()
plt.show()


phase = np.angle(fft_result)

# Plot Phase Spectrum
plt.figure(figsize=(10, 5))
plt.stem(freqs, phase)
plt.xlabel("Normalized Frequency")
plt.ylabel("Phase (radians)")
plt.title("Phase Spectrum")
plt.grid()
plt.show()


# Extract real and imaginary parts
real_part = np.real(fft_result)
imag_part = np.imag(fft_result)

# Plot Real and Imaginary Parts
plt.figure(figsize=(10, 5))
plt.stem(freqs, real_part, markerfmt='bo', linefmt='b-', basefmt=" ")
plt.stem(freqs, imag_part, markerfmt='ro', linefmt='r-', basefmt=" ")
plt.xlabel("Normalized Frequency")
plt.ylabel("Amplitude")
plt.legend(["Real Part", "Imaginary Part"])
plt.title("Real and Imaginary Parts of FFT")
plt.grid()
plt.show()
