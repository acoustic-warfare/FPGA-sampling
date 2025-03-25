import numpy as np
from pathlib import Path
import os
import matplotlib.pyplot as plt
import struct


def load_data_from_FPGA(path):
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 68)  # Each row: 4 header fields + 64 mic data values
    sample_nr = data2D[:, 2]  # take sample nr normalize it and divde by 32
    sample_nr = (sample_nr - sample_nr[0])/32  # take sample nr normalize it and divde by 32
    subband_info = data2D[:, 3]  # Extract subband column (4th column, index 3)
    mic_data = data2D[:, 4:]  # Microphone data starts from column 5 (index 4)
    f_sampling = 48828.125/32  # Hz
    return mic_data, f_sampling, sample_nr, subband_info


def divide_data_to_subbands(mic_data, sample_nr, subband_info):
    subband_divided_mic_data = [[] for _ in range(32)]

    for row in range(len(mic_data)):
        if sample_nr[row] > 0 and sample_nr[row] < sample_nr[len(sample_nr) - 1]:  # remove some first and last samples to make the array nice and even
            subband_index = subband_info[row]
            combined_row = np.concatenate(([sample_nr[row] - 1], mic_data[row])).tolist()
            subband_divided_mic_data[subband_index].append(combined_row)

    return subband_divided_mic_data


def take_out_mic_data(subband_divided_mic_data, mic_nr):
    return np.array([[[row[0], row[mic_nr + 1]] for row in band]for band in subband_divided_mic_data])  # sorry for this row but it works :)


def exponential_moving_average(input_signal, alpha_rise, alpha_fall):
    if not (0 < alpha_rise <= 1) or not (0 < alpha_fall <= 1):
        raise ValueError("Alpha must be in the range (0, 1].")
    input_signal = np.abs(input_signal) ** 2
    ema_signal = np.zeros_like(input_signal)
    ema_signal[0] = 0  # Initialize with the first value

    for i in range(1, len(input_signal)):
        if input_signal[i] > ema_signal[i - 1]:
            ema_signal[i] = alpha_rise * input_signal[i] + (1 - alpha_rise) * ema_signal[i - 1]
        else:
            ema_signal[i] = alpha_fall * input_signal[i] + (1 - alpha_fall) * ema_signal[i - 1]
    return ema_signal


def plot_32_subplots(plt_data, allowed_subbands):
    fig, axes = plt.subplots(8, 4, figsize=(15, 20))  # 8 rows, 4 columns
    axes = axes.flatten()

    global_min = np.min(plt_data[:, 2000:]) * 0.9
    global_max = np.max(plt_data[:, 2000:]) * 1.1
    if global_min == 0:
        global_min = -0.1

    original_index = 0
    for allowed in allowed_subbands:
        ax = axes[original_index]
        subband_data = plt_data[original_index, :]  # Select the data from the second channel
        ax.plot(subband_data)
        ax.set_ylim(global_min, global_max)  # Set the y-axis limits
        if allowed == 1:
            ax.text(0.5, 0.87, f"Subband {original_index}", transform=ax.transAxes, ha='center', va='bottom')
        else:
            ax.text(0.5, 0.87, f"Subband {original_index} (Removed)", transform=ax.transAxes, ha='center', va='bottom')
        original_index += 1

    plt.tight_layout()


def amplitude_lock(ema_data, allowed_subbands):
    amplitude_lock_data = np.zeros_like(ema_data)

    for col in range(ema_data.shape[1]):
        valid_indices = np.where(allowed_subbands)[0]

        if len(valid_indices) > 0:
            amplitude_max = np.max(ema_data[valid_indices, col])

            for i in valid_indices:
                if ema_data[i, col] > amplitude_max / 4:  # 5 = magic number :mage:
                    amplitude_lock_data[i, col] = 1

    return amplitude_lock_data


def post_processing(mic_data_all, amplitude_lock_data):

    post_process_data = [[] for _ in range(32)]

    for subband in range(len(amplitude_lock_data)):
        for row in range(len(amplitude_lock_data[0])):
            if amplitude_lock_data[subband, row] == 1:
                post_process_data[subband].append(mic_data_all[subband][row])

    return post_process_data


def int_to_twos_complement_string(num, bits=32):
    """Convert integer to two's complement binary string."""
    num = int(num)
    if num >= 0:
        binary = bin(num)[2:].zfill(bits)
    else:
        binary = bin((1 << bits) + num)[2:]
    return " ".join(binary[i:i+8] for i in range(0, bits, 8))


def save_to_subband_file(post_process_data, base_name="recording"):
    output_dir = Path(os.getcwd()) / "recorded_data"
    output_dir.mkdir(parents=True, exist_ok=True)  # Ensure directory exists

    for subband_nr, data in enumerate(post_process_data):
        if data:
            file_path_bin = output_dir / f"{base_name}_{subband_nr}.bin"
            file_path_txt = output_dir / f"{base_name}_{subband_nr}.txt"

            with open(file_path_bin, "wb") as f:
                np.array(data, dtype=np.int32).tofile(f)  # Save as int32

            with open(file_path_txt, "w") as txt_file:
                for row in data:  # Iterate over all samples
                    txt_file.write(f"pl_counter: {int(row[0]):04d}    ")
                    for i in range(1, len(row)):
                        txt_file.write(f"mic_{i - 1}: {int_to_twos_complement_string(row[i])}  ")
                    txt_file.write("\n")

            print(f"Saved: {file_path_bin}")
        else:
            print(f"Skipping empty subband {subband_nr}")


def save_to_combined_file(post_process_data, file_name="recording_combined"):
    output_dir = Path(os.getcwd()) / "recorded_data"
    output_dir.mkdir(parents=True, exist_ok=True)  # Ensure directory exists

    file_path_bin = output_dir / f"{file_name}.bin"
    file_path_txt = output_dir / f"{file_name}.txt"

    all_samples = []
    for subband_nr, subband_data in enumerate(post_process_data):
        if subband_data:
            all_samples.extend(subband_data)  # Collect all samples

    # Sort samples by pl_counter (first element of each row)
    all_samples.sort(key=lambda x: x[0])

    with open(file_path_bin, "wb") as f_bin, open(file_path_txt, "w") as f_txt:
        for row in all_samples:
            f_bin.write(np.array(row, dtype=np.int32).tobytes())  # Save binary data

            f_txt.write(f"pl_counter: {int(row[0]):04d}    ")
            for i in range(1, len(row)):
                f_txt.write(f"mic_{i}: {int_to_twos_complement_string(row[i])}  ")
            f_txt.write("\n")

    print(f"Saved combined files: {file_path_bin}, {file_path_txt}")


# --------------------------------- main ---------------------------------
# Extract one subband
input_file = "noise"
# input_file = "drone_front"
# input_file = "drone_right"
# input_file = "4000Hz_front"
# input_file = "4000Hz_right"

input_file_path_bin = Path(os.getcwd()) / "recorded_data" / f"{input_file}.bin"

# load mic data
mic_data_all, f_sampling, sample_nr, subband_info = load_data_from_FPGA(input_file_path_bin)
print("\npreforming moving average on: ", input_file, "\n")
print("mic_data_all shape:", mic_data_all.shape)
print("mic_data_all variance:", np.var(mic_data_all), "\n")

print("sample_nr", sample_nr)
print("subband_info", subband_info)

mic_data_all = divide_data_to_subbands(mic_data_all, sample_nr, subband_info)

mic_nr = 35  # 0 to 63
mic_data = take_out_mic_data(mic_data_all, mic_nr)

# remove noisy subbands
# subband number    0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
allowed_subbands = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

plot_32_subplots(np.abs(mic_data[:, :, 1]) ** 2, allowed_subbands)

alpha_rise = 1/(2**4)
alpha_fall = 1/(2**4)

ema_data = []
for i in range(0, len(mic_data)):
    ema = exponential_moving_average(mic_data[i, :, 1], alpha_rise, alpha_fall)
    ema_data.append(ema)

ema_data = np.array(ema_data)

plot_32_subplots(ema_data, allowed_subbands)

print(ema_data.shape)

amplitude_lock_data = amplitude_lock(ema_data, allowed_subbands)

plot_32_subplots(amplitude_lock_data, allowed_subbands)

post_process_data_all = post_processing(mic_data_all, amplitude_lock_data)

save_to_subband_file(post_process_data_all)

save_to_combined_file(post_process_data_all)


plt.show()
