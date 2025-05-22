import numpy as np
import os
from pathlib import Path
import matplotlib.pyplot as plt


def load_data_FPGA(fileChooser):
    ROOT = os.getcwd()
    path = Path(ROOT + "/recorded_data/v21/" + fileChooser + ".bin")
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)

    try:
        nr_subbands = 64
        data2D = data.reshape(-1, 259)
        subband_info = data2D[:, 2] >> 24
        mic_data = data2D[:, 3:]
        sample_counter = data2D[:, 2].astype(np.uint32) & 0x00FFFFFF
        sample_counter = (sample_counter - sample_counter[0]) / nr_subbands
    except ValueError:
        nr_subbands = 32
        data2D = data.reshape(-1, 68)
        subband_info = data2D[:, 3]
        mic_data = data2D[:, 4:]
        sample_counter = data2D[:, 2]
        sample_counter = (sample_counter - sample_counter[0]) / nr_subbands

    sample_counter = sample_counter.astype(int)
    f_sampling = 48828.125
    return mic_data, sample_counter, subband_info, f_sampling, nr_subbands


def process_mic_data(fileChooser, mic_nr=0):
    mic_data, sample_counter, subband_info, f_sampling, nr_subbands = load_data_FPGA(fileChooser)

    mic_data = mic_data[:, :128]
    mic_data_real = mic_data[:, 0::2].astype(np.float32)
    mic_data_imag = mic_data[:, 1::2].astype(np.float32)

    mic_data_power = mic_data_real**2 + mic_data_imag**2
    mic_data_power_mic = mic_data_power[:, mic_nr]

    unique_samples, inverse_indices = np.unique(sample_counter, return_inverse=True)
    num_samples = len(unique_samples)
    result_array = np.zeros((num_samples, nr_subbands))

    for i in range(len(mic_data_power_mic)):
        row = inverse_indices[i]
        col = subband_info[i]
        result_array[row, col] = mic_data_power_mic[i]

    return result_array, f_sampling, nr_subbands, len(mic_data), fileChooser


def db(x):
    return 20 * np.log10(np.maximum(x, 1e-12))  # avoid log(0)


# === Configurable Settings ===
file1 = "4k_subband_decode"
file2 = "4k_fft_hamm_decode"

freq_range1 = (2000, 20000)         # in Hz
freq_range2 = (0, 48828.125 / 2)    # in Hz

mic_nr = 0

# === Process Files ===
data1, fs1, bands1, len1, label1 = process_mic_data(file1, mic_nr)
data2, fs2, bands2, len2, label2 = process_mic_data(file2, mic_nr)

time_axis1 = np.arange(len(data1)) / fs1 * bands1
time_axis2 = np.arange(len(data2)) / fs2 * bands2
freq_axis1 = np.linspace(freq_range1[1], freq_range1[0], bands1)
freq_axis2 = np.linspace(freq_range2[1], freq_range2[0], bands2)

# === Spectrogram Plots ===
fig, axs = plt.subplots(1, 2, figsize=(14, 6))

im0 = axs[0].imshow(db(data1).T[::-1, :], cmap='viridis', aspect='auto',
                    extent=[time_axis1[0], time_axis1[-1], freq_range1[0], freq_range1[1]])
axs[0].set_title(f"{label1} - Spectrogram")
axs[0].set_xlabel("Time (s)")
axs[0].set_ylabel("Frequency (Hz)")
plt.colorbar(im0, ax=axs[0])

im1 = axs[1].imshow(db(data2).T[::-1, :], cmap='viridis', aspect='auto',
                    extent=[time_axis2[0], time_axis2[-1], freq_range2[0], freq_range2[1]])
axs[1].set_title(f"{label2} - Spectrogram")
axs[1].set_xlabel("Time (s)")
axs[1].set_ylabel("Frequency (Hz)")
plt.colorbar(im1, ax=axs[1])

plt.tight_layout()
plt.savefig(f"./recorded_data/v21/images/spectrogram_compare_{file1}_vs_{file2}.png")
plt.savefig(f"./recorded_data/v21/images/spectrogram_compare_{file1}_vs_{file2}.pdf")

# === Average Magnitude Plot (Flipped Frequency Axis) ===
avg1 = np.mean(data1, axis=0)
avg2 = np.mean(data2, axis=0)

plt.figure(figsize=(12, 5))
plt.plot(freq_axis1[::-1], db(avg1), label=label1)
plt.plot(freq_axis2[::-1], db(avg2), label=label2)
plt.title("Average Magnitude vs Frequency (Flipped)")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude (dB)")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig(f"./recorded_data/v21/images/avg_freq_response_flipped_{file1}_vs_{file2}.png")
plt.savefig(f"./recorded_data/v21/images/avg_freq_response_flipped_{file1}_vs_{file2}.pdf")

plt.show()

# === Info Printout ===
expected_nr_samples = 48828.125 * 5
for label, count, bands in [(label1, len1, bands1), (label2, len2, bands2)]:
    print(f"\n{label}")
    print(f"number of samples: {count / expected_nr_samples * 100:.2f}%")
    if bands == 64:
        print(f"bandwidth:         {count / expected_nr_samples * 100 * 2:.2f}%")
    else:
        print(f"bandwidth:         {count / expected_nr_samples * 100:.2f}%")
