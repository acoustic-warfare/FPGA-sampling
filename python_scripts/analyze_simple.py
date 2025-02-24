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
        mic_samples = micData[subband_indices, mic_nr - 1]

        # Truncate to min_len
        subband_data.append(mic_samples[:min_len])

    return np.vstack(subband_data), unique_subbands


def plot_mic_data_fft(subband_data, unique_subbands, f_sampling, mic_nr, max_freq=4000):
    plt.figure(figsize=(12, 8))

    for subband in unique_subbands:
        # Get data for this subband
        mic_data = subband_data[int(subband)]

        if len(mic_data) == 0:
            continue

        # Calculate FFT
        n = len(mic_data)
        fft_result = np.fft.fft(mic_data)
        freq = np.fft.fftfreq(n, d=1/f_sampling)

        # Keep only positive frequencies up to max_freq
        positive_freq_mask = (freq >= 0) & (freq <= max_freq)
        freq = freq[positive_freq_mask]
        fft_result = np.abs(fft_result[positive_freq_mask]) / n

        # Plot
        plt.plot(freq, fft_result, label=f"Subband {subband}")

    plt.title(f"Frequency Spectrum of Microphone {mic_nr}")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Amplitude (Normalized)")
    plt.xlim(0, max_freq)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.legend()
    plt.tight_layout()
    plt.show()


# Main execution block
print("Enter a file to plot: ")
fileChooser = input()
mic_nr = 35  # Selecting microphone number 35

# Load data
micData, subband_info, f_sampling = load_data_FPGA(fileChooser)

# Split data by subbands for specific microphone
subband_data, unique_subbands = split_to_subbands_for_mic(micData, subband_info, mic_nr)


print(f"Unique subbands: {unique_subbands}")
print(f"Number of subbands: {len(unique_subbands)}")
print(f"Number of samples in recording: {len(subband_info)}")

# Print samples per subband
for subband in unique_subbands:
    sb = int(subband)
    print(f"Subband {sb}: {len(subband_data[sb])} samples")

# Plot FFT for each subband
# plot_mic_data_fft(subband_data, unique_subbands, f_sampling, mic_nr)


# take the power from the downsampled signal

print("output length:", len(subband_data[0]))
print(np.array(subband_data))

subband_data_power = np.abs(subband_data)**2


def db(x):
    return 10*np.log10(x)


plt.imshow(db(subband_data_power.T), cmap='viridis', aspect='auto')
plt.colorbar()
plt.xlabel("Channel")
plt.ylabel("Time")
plt.show()
