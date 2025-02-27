import numpy as np
import os
from pathlib import Path
import matplotlib.pyplot as plt


def load_data_FPGA(fileChooser):
    ROOT = os.getcwd()
    path = Path(ROOT + "/recorded_data/" + fileChooser + ".bin")
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 68)  # Each row: 4 header fields + 64 mic data values
    subband_info = data2D[:, 3]  # Extract subband column (4th column, index 3)
    micData = data2D[:, 4:]  # Microphone data starts from column 5 (index 4)
    f_sampling = 48828.125  # Hz
    return micData, subband_info, f_sampling


def split_to_subbands_for_mic(micData, subband_info, mic_nr):
    unique_subbands = np.unique(subband_info)
    subband_data = []

    min_len = min(np.sum(subband_info == subband) for subband in unique_subbands)

    for subband in unique_subbands:
        subband_indices = np.where(subband_info == subband)[0]
        mic_samples = micData[subband_indices, mic_nr]

        # Truncate to min_len
        subband_data.append(mic_samples[:min_len])

    return np.vstack(subband_data), unique_subbands


# Main execution block
print("Enter a file to plot: ")
fileChooser = input()
mic_nr = 0  # (0 - 63) Selecting microphone number 35

# Load data
micData, subband_info, f_sampling = load_data_FPGA(fileChooser)

# Split data by subbands for specific microphone
subband_data, unique_subbands = split_to_subbands_for_mic(micData, subband_info, mic_nr)


print(f"Unique subbands: {unique_subbands}")
print(f"Number of subbands: {len(unique_subbands)}")
print(f"Number of samples in recording: {len(subband_info)}")
print(f"Number of samples per sub-band: {len(subband_data[0])}")

subband_data_power = np.abs(subband_data)**2


def db(x):
    x = np.where(x > 0, x, np.finfo(float).eps)  # Replace zeros and negatives with a very small positive value
    return 10 * np.log10(x)


plt.imshow(db(subband_data_power.T), cmap='viridis', aspect='auto')
plt.colorbar()
plt.xlabel("Channel")
plt.ylabel("Time")
plt.show()


def plot_fft_subband(subband_data, sampling_rate=1):
    num_subbands = subband_data.shape[0]

    plt.figure(figsize=(12, 8))

    for i in range(num_subbands):
        signal = subband_data[i, :]
        fft_values = np.fft.fft(signal)
        freqs = np.fft.fftfreq(len(signal), d=1/sampling_rate)

        plt.subplot(num_subbands, 1, i + 1)
        plt.plot(freqs[:len(freqs)//2], np.abs(fft_values[:len(freqs)//2]))  # Plot only positive frequencies
        # plt.title(f'Subband {i + 1} FFT')
        # plt.xlabel('Frequency (Hz)')
        # plt.ylabel('Magnitude')
        plt.grid()

    plt.show()

# plot_fft_subband(subband_data)
