import numpy as np
import os
from pathlib import Path
import matplotlib.pyplot as plt


def load_data_FPGA(fileChooser):
    ROOT = os.getcwd()
    path = Path(ROOT + "/recorded_data/v21_2/" + fileChooser + ".bin")
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)

    try:  # fft-channelizer fomat
        nr_subbands = 64
        # Try format 1: 259 columns (e.g., 4 headers + 255 mic/subband data)
        data2D = data.reshape(-1, 259)
        subband_info = data2D[:, 2] >> 24  # Extract subband from column 3 (index 2)
        mic_data = data2D[:, 3:]  # Microphone data starts from column 4
        sample_counter = data2D[:, 2].astype(np.uint32) & 0x00FFFFFF
        sample_counter = (sample_counter - sample_counter[0]) / nr_subbands

    except ValueError:  # subband-channelizer format
        nr_subbands = 32
        # Fallback to format 2: 68 columns (e.g., 4 headers + 64 mic data)
        data2D = data.reshape(-1, 68)
        subband_info = data2D[:, 3]  # Extract subband from column 4
        mic_data = data2D[:, 4:]  # Microphone data starts from column 5
        sample_counter = data2D[:, 2]
        sample_counter = (sample_counter - sample_counter[0]) / nr_subbands

    sample_counter = sample_counter.astype(int)
    f_sampling = 48828.125  # Hz
    return mic_data, sample_counter, subband_info, f_sampling, nr_subbands


# Main execution block
print("Enter a file to plot: ")
fileChooser = input()
# fileChooser = "recive_and_plot"
mic_nr = 0  # (0 - 63) Selecting microphone number 35

# Load data
mic_data, sample_counter, subband_info, f_sampling, nr_subbands = load_data_FPGA(fileChooser)

expected_nr_samples = 48828.125 * 5
nr_samples = len(mic_data)
if nr_samples < expected_nr_samples * 0.9:
    decode = 1
else:
    decode = 0

print("nr_subbands", nr_subbands)

if nr_subbands == 64:
    mic_data = mic_data[:, :128]
    mic_data_real = mic_data[:, 0::2]  # even indices: 0, 2, 4, ...
    mic_data_imag = mic_data[:, 1::2]  # odd indices: 1, 3, 5, ...
    mic_data_real = mic_data_real.astype(np.float32)
    mic_data_imag = mic_data_imag.astype(np.float32)

    mic_data_power = (mic_data_real**2 + mic_data_imag**2) / 2**0.5
else:
    mic_data_power = mic_data.astype(np.float32) ** 2

mic_data_power_mic = mic_data_power[:, mic_nr]


unique_samples, inverse_indices = np.unique(sample_counter, return_inverse=True)
num_samples = len(unique_samples)
result_array = np.zeros((num_samples, nr_subbands))  # 64 subbands

# Fill in the result_array
for i in range(len(mic_data_power_mic)):
    row = inverse_indices[i]                # maps to 0..num_samples-1
    col = subband_info[i]                   # 0..63
    result_array[row, col] = mic_data_power_mic[i]

print("min (non-zero):", np.min(result_array[result_array > 0]))


def db(x):
    # if decode == 1:
    # eps = np.min(result_array[result_array > 0])
    # return 20 * np.log10(x + eps)
    # else:
    return 20 * np.log10(x)


time_axis = np.arange(len(result_array)) / f_sampling * nr_subbands  # X-axis: Time = (bin_index / Fs) * FFT_size

if nr_subbands == 64:
    freq_range = [0, f_sampling/2]
else:
    freq_range = [1000, f_sampling/2]

# freq_range = [0, f_sampling/2]
# freq_range = [3000, 5000]
# freq_range = [1000, f_sampling/2]

freq_axis = np.linspace(freq_range[1], freq_range[0], nr_subbands)  # Y-axis: Frequency goes from f_sampling / 2 (top) to 0 (bottom)

plt.figure(0)
# plt.imshow(db(result_array).T[::-1, :] - 40,  # [::-1, :] is to flip the y axis
#           cmap='viridis',
#           aspect='auto',
#           extent=[time_axis[0], time_axis[-1], freq_axis[-1], freq_axis[0]])

offset = 60
result_array = result_array
db_result = db(result_array) - offset
plt.imshow(db_result.T[::-1, :],
           cmap='viridis',
           aspect='auto',
           extent=[time_axis[0], time_axis[-1], freq_axis[-1], freq_axis[0]],

           vmin=20*np.log10(np.percentile(result_array[result_array > 1], 1)) - offset - 10,
           vmax=20*np.log10(np.percentile(result_array, 99)) - offset
           )


plt.colorbar()
plt.xlabel("Time (s)")
plt.ylabel("Frequency (Hz)")

plt.savefig("./recorded_data/v21_2/images/" + fileChooser + ".png")
plt.savefig("./recorded_data/v21_2/images/" + fileChooser + ".pdf")


# plt.savefig("../ExJobb_Rapport/images/results/" + fileChooser + ".pdf")

average_magnitude = np.mean(result_array, axis=0)

plt.figure(1)


plt.plot(db(average_magnitude))

# plt.savefig("./recorded_data/v21_2/images/" + fileChooser + "_average.png")
# plt.savefig("./recorded_data/v21_2/images/" + fileChooser + "_average.pdf")

print("\n", fileChooser)
print(f"number of samples {nr_samples / expected_nr_samples * 100:.2f}%")
if nr_subbands == 64:  # bad code but the fft have 50% overlap and gets a * 2 becouse of real, imm numbers
    print(f"bandwidht         {nr_samples / expected_nr_samples * 100 * 2:.2f}% \n")
else:
    print(f"bandwidht         {nr_samples / expected_nr_samples * 100:.2f}% \n")


plt.show()
