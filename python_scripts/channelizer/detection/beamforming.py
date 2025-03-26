import numpy as np
import os
from pathlib import Path
import matplotlib.pyplot as plt
from scipy import signal
import struct


def int_to_twos_complement_string(num, bits=32):
    """Convert integer to two's complement binary string."""
    if num >= 0:
        binary = bin(num)[2:].zfill(bits)
    else:
        binary = bin((1 << bits) + num)[2:]
    return " ".join(binary[i:i+8] for i in range(0, bits, 8))


def int_to_twos_string_header(num, bits=32):
    """Convert integer to two's complement binary string for header."""
    if num >= 0:
        binary = bin(num)[2:].zfill(bits)
    else:
        binary = bin((1 << bits) + num)[2:]
    return binary[0:7] + " " + binary[8:15] + " " + binary[16:31]


def filter_and_save_bin_and_txt(subband_to_save, bin_path, filtered_bin_path, filtered_txt_path):
    max_rows = 488828*10  # max data length
    nr_arrays = 1

    with open(bin_path, "rb") as bin_file, \
            open(filtered_bin_path, "wb") as filtered_bin, \
            open(filtered_txt_path, "w") as filtered_txt:

        for row in range(max_rows):
            # Read one full data packet (header + sampleCounter + PL_counter + subband_nr + 64 microphones)
            data_packet = bin_file.read(4 + 4 + 4 + 4 + (64 * 4 * nr_arrays))
            if not data_packet:
                break  # Stop when no more data

            # Unpack the binary data
            header, sample_counter, pl_counter, subband_nr, *mic_data = struct.unpack("<iiii64i", data_packet)

            if subband_nr == subband_to_save:
                filtered_bin.write(data_packet)  # Save the row to the new binary file

                # Write to the text file
                filtered_txt.write(f"header: {int_to_twos_string_header(header)}    ")
                filtered_txt.write(f"sample_counter: {sample_counter}    ")
                filtered_txt.write(f"pl_counter: {pl_counter}    ")
                filtered_txt.write(f"subband_nr: {subband_nr:03d}    ")

                for i, mic in enumerate(mic_data):
                    filtered_txt.write(f"mic_{i}: {int_to_twos_complement_string(mic)}  ")

                filtered_txt.write("\n")

    # print(f"Filtered binary file saved as {filtered_bin_path}")
    # print(f"Filtered text file saved as {filtered_txt_path}")


def load_data_FPGA(path):
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 68)  # Each row: 4 header fields + 64 mic data values
    subband_info = data2D[:, 3]  # Extract subband column (4th column, index 3)
    micData = data2D[:, 4:]  # Microphone data starts from column 5 (index 4)
    f_sampling = 48828.125/32  # Hz
    return micData, f_sampling


# --------------------------------- beamforming ---------------------------------
# Constants that should never be changed (if we dont run the system on Mars since there c = 240 m/s becouse of the lower density of the atmosphere)
c = 343  # Speed of sound in air (m/s)
d = 0.02  # Distance between microphones (m) - 2 cm between the elemnts
Nx, Ny = 8, 8  # 8x8 microphone array


def compute_delays(theta, phi, fs):
    delays = np.zeros((Nx, Ny))

    for x in range(Nx):
        for y in range(Ny):
            # Convert from array indices to physical coordinates
            # Origin (0,0) at center of array
            dx = (x - (Nx - 1) / 2) * d  # x increases from left to right
            dy = ((Ny - 1) / 2 - y) * d  # y increases from bottom to top

            # Calculate delay based on direction of arrival
            delay_time = (dx * np.sin(phi) + dy * np.sin(theta)) / c
            delays[y, x] = delay_time * fs

    return delays


def upsample_signals(micData, factor):
    n_samples, n_mics = micData.shape
    upsampled = np.zeros((n_samples * factor, n_mics))

    for i in range(n_mics):
        # Use sinc interpolation for high-quality upsampling
        upsampled[:, i] = signal.resample(micData[:, i], n_samples * factor)

    return upsampled


def delay_and_sum(micData, fs, theta_range, phi_range):
    # Upsample the data
    upsampled_data = upsample_signals(micData, upsampling_factor)
    upsampled_fs = fs * upsampling_factor

    print(f"Data shape after upsampling: {upsampled_data.shape}")

    power_map = np.zeros((len(theta_range), len(phi_range)))

    print("Computing beamforming map...")
    # Iterate through all angles
    for i, theta in enumerate(theta_range):
        if i % 10 == 0:
            print(f"Processing elevation angle {i}/{len(theta_range)}")

        for j, phi in enumerate(phi_range):
            # Convert angles to radians
            theta_rad = np.radians(theta)
            phi_rad = np.radians(phi)

            delays = compute_delays(theta_rad, phi_rad, upsampled_fs)
            delayed_signals = np.zeros_like(upsampled_data[:, 0], dtype=np.float64)

            for x in range(Nx):
                for y in range(Ny):
                    #mic_idx = y * Nx + x
                    mic_idx = x * Ny + y 

                    delay = int(round(delays[y, x]))

                    if delay >= 0:
                        if delay < upsampled_data.shape[0]:
                            shifted_signal = np.pad(upsampled_data[:-delay or None, mic_idx],
                                                    (delay, 0), mode='constant')
                        else:
                            shifted_signal = np.zeros_like(upsampled_data[:, 0])
                    else:
                        abs_delay = abs(delay)
                        if abs_delay < upsampled_data.shape[0]:
                            shifted_signal = np.pad(upsampled_data[abs_delay:, mic_idx],
                                                    (0, abs_delay), mode='constant')
                        else:
                            shifted_signal = np.zeros_like(upsampled_data[:, 0])

                    delayed_signals += shifted_signal

            power_map[i, j] = np.var(delayed_signals)

    print("Normalizing power map...")
    power_map -= power_map.min()
    max_val = power_map.max()
    if max_val > 0:
        power_map /= max_val

    return power_map


# --------------------------------- main ---------------------------------
# Extract one subband
subband_to_save = 14
input_file = "drone_front"
# input_file = "drone_right"
# input_file = "4000Hz_front"
#input_file = "4000Hz_right"

output_file = input_file + "_subband_" + str(subband_to_save)
input_file_path_bin = Path(os.getcwd()) / "recorded_data" / f"{input_file}.bin"
output_file_path_bin = Path(os.getcwd()) / "recorded_data" / f"{output_file}.bin"
output_file_path_txt = Path(os.getcwd()) / "recorded_data" / f"{output_file}.txt"

print("Extracting subband: ", subband_to_save)
print(f"From file: {input_file}.bin")
print(f"To file:   {output_file}.bin", "\n")

filter_and_save_bin_and_txt(subband_to_save, input_file_path_bin, output_file_path_bin, output_file_path_txt)

# load mic data
micData, f_sampling = load_data_FPGA(output_file_path_bin)
print("MicData shape:", micData.shape)
print("MicData variance:", np.var(micData), "\n")

# preforme beamorming
upsampling_factor = 10  # At least 6 but preferibly 10
f_upsampled = f_sampling * upsampling_factor

theta_range = np.linspace(-90, 90, 20)  # Elevation angles
phi_range = np.linspace(-90, 90, 20)    # Azimuth angles

print("Starting beamforming computation...")
power_map = delay_and_sum(micData, f_sampling, theta_range, phi_range)

power_map = power_map ** 3  # this is a magic number :mage_man:

# --------------------------------- plot ---------------------------------
plt.figure(figsize=(10, 8))
plt.imshow(power_map, extent=[-90, 90, -90, 90], origin='lower', aspect='auto', cmap='jet')
plt.colorbar(label='Normalized Beamformed Power')
plt.xlabel('Azimuth Angle (degrees)')
plt.ylabel('Elevation Angle (degrees)')
plt.title('Beamforming')
plt.grid(True, linestyle='--', alpha=0.6)
plt.tight_layout()
plt.show()
