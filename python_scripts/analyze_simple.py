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
    mic_data = data2D[:, 4:]  # Microphone data starts from column 5 (index 4)
    sample_counter = data2D[:, 2]
    sample_counter = (sample_counter - sample_counter[0])/32
    sample_counter = sample_counter.astype(int)

    f_sampling = 48828.125  # Hz
    return mic_data, sample_counter, subband_info, f_sampling


# def split_to_subbands_for_mic(mic_data, sample_counter, subband_info, mic_nr):
#    unique_subbands = np.unique(subband_info)
#    subband_data = []
#
#    min_len = min(np.sum(subband_info == subband) for subband in unique_subbands)
#
#    for subband in unique_subbands:
#        subband_indices = np.where(subband_info == subband)[0]
#        mic_samples = mic_data[subband_indices, mic_nr]
#
#        # Truncate to min_len
#        subband_data.append(mic_samples[:min_len])
#
#    return np.vstack(subband_data), unique_subbands


def split_to_subbands_for_mic(all_mic_data, sample_counter, subband_info, mic_nr):
    mic_data = all_mic_data[:, mic_nr]

    # Determine the number of unique samples
    unique_samples = sorted(set(sample_counter))
    num_samples = len(unique_samples)

    sample_index_map = {sample: idx for idx, sample in enumerate(unique_samples)}

    subband_divided_mic_data = np.zeros((num_samples, 32), dtype=int)

    for i in range(len(sample_counter)):
        sample_idx = sample_index_map[sample_counter[i]]  # Get row index
        subband_idx = subband_info[i]  # Column index (subband number)
        subband_divided_mic_data[sample_idx][subband_idx] = mic_data[i]  # Assign value

    return subband_divided_mic_data


def count_nonzero_per_subband(subband_data):
    nonzero_counts = np.count_nonzero(subband_data, axis=0)  # Count non-zero per subband

    # Print results
    for subband, count in enumerate(nonzero_counts):
        print(f"Subband {subband:02d}: {count}")

    return nonzero_counts  # In case you want to use it later


# Main execution block
print("Enter a file to plot: ")
# fileChooser = input()
fileChooser = "recive_and_plot"
mic_nr = 35  # (0 - 63) Selecting microphone number 35

# Load data
mic_data, sample_counter, subband_info, f_sampling = load_data_FPGA(fileChooser)

# Split data by subbands for specific microphone
subband_data = split_to_subbands_for_mic(mic_data, sample_counter, subband_info, mic_nr)


print("Unique subbands: ", np.unique(subband_info).tolist())
print(f"Number of subbands: {len(np.unique(subband_info))}")
print(f"Number of samples in recording: {len(subband_info)}")
print(f"Number of samples per sub-band: {len(subband_data[0])}")

subband_data_power = np.abs(subband_data)**2


def db(x):
    # x = np.where(x > 0, x, np.finfo(float).eps)  # Replace zeros and negatives with a very small positive value
    return 10 * np.log10(x)


plt.imshow(db(subband_data_power), cmap='viridis', aspect='auto')
plt.colorbar()
plt.xlabel("Channel")
plt.ylabel("Time")
plt.show()

nonzero_counts = count_nonzero_per_subband(subband_data)
