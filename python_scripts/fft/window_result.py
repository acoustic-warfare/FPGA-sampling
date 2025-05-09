import numpy as np
import os
from pathlib import Path
import matplotlib.pyplot as plt


def load_data_FPGA(fileChooser):
    ROOT = os.getcwd()
    path = Path(ROOT + "/recorded_data/" + fileChooser + ".bin")
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)

    try:  # fft-channelizer format
        nr_subbands = 64
        data2D = data.reshape(-1, 259)
        subband_info = data2D[:, 2] >> 24
        mic_data = data2D[:, 3:]
        sample_counter = data2D[:, 2].astype(np.uint32) & 0x00FFFFFF
        sample_counter = (sample_counter - sample_counter[0]) / nr_subbands
    except ValueError:  # subband-channelizer format
        nr_subbands = 32
        data2D = data.reshape(-1, 68)
        subband_info = data2D[:, 3]
        mic_data = data2D[:, 4:]
        sample_counter = data2D[:, 2]
        sample_counter = (sample_counter - sample_counter[0]) / nr_subbands

    sample_counter = sample_counter.astype(int)
    f_sampling = 48828.125  # Hz
    return mic_data, sample_counter, subband_info, f_sampling, nr_subbands


def db(x):
    return 20 * np.log10(np.maximum(x, 1e-10))  # Prevent log(0)


# List of input files
input_file_names = ["4k_fft_rect", "4k_fft_hamm", "4k_fft_hann"]

mic_nr = 0  # Choose the microphone index to process (e.g., 0–63)

plt.figure(figsize=(10, 6))

for fileChooser in input_file_names:
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

    # Compute average magnitude response for this file
    average_magnitude = np.mean(result_array, axis=0)
    plt.plot(db(average_magnitude), label=fileChooser)

# Final plot setup
plt.title("Average Magnitude Response per Input File")
plt.xlabel("Subband Index")
plt.ylabel("Magnitude (dB)")
plt.legend()
plt.grid(True)
plt.tight_layout()

plt.savefig("./recorded_data/images/window_result.png")
plt.savefig("./recorded_data/images/window_result.pdf")
plt.show()
