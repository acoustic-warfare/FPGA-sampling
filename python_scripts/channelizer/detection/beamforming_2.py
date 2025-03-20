from scipy.signal import resample
import os
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
from scipy.interpolate import interp1d


def read_bin_file(bin_path):
    data = np.fromfile(bin_path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 65)  # Each row: 4 header fields + 64 mic data values
    sample_counter = data2D[:, 0]
    micData = data2D[:, 1:]
    return sample_counter, micData


def read_bin_file_fpga(bin_path):
    data = np.fromfile(bin_path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 68)  # Each row: 4 header fields + 64 mic data values
    sample_counter = data2D[:, 2]
    sample_counter = (sample_counter - sample_counter[0])/32
    subband_nr = data2D[:, 3]
    micData = data2D[:, 4:]
    return sample_counter, subband_nr, micData


def process_data(sample_counter, micData):
    unique_counters = np.unique(sample_counter)
    processed_data = np.zeros((len(unique_counters), micData.shape[1]))

    for i, counter in enumerate(unique_counters):
        indices = np.where(sample_counter == counter)[0]
        processed_data[i, :] = np.sum(micData[indices, :], axis=0)

    # Interpolate missing samples
    full_range = np.arange(unique_counters[0], unique_counters[-1] + 1)
    interpolated_data = np.zeros((len(full_range), micData.shape[1]))

    for mic in range(micData.shape[1]):
        f = interpolate.interp1d(unique_counters, processed_data[:, mic], kind='linear', fill_value='extrapolate')
        interpolated_data[:, mic] = f(full_range)

    return interpolated_data


# --------------------------------- beamforming ---------------------------------
# Constants that should never be changed (if we dont run the system on Mars since there c = 240 m/s becouse of the lower density of the atmosphere)
c = 343  # Speed of sound in air (m/s)
d = 0.02  # Distance between microphones (m) - 2 cm between the elements
Nx, Ny = 8, 8  # 8x8 microphone array
upsample_factor = 2  # to reduce the error


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
            delays[y, x] = delay_time * fs * upsample_factor

    return delays


def apply_delay(signal, delay_samples):
    n = len(signal)
    x = np.arange(n)
    delayed_x = x - delay_samples  # Shift indices by fractional delay

    resampled_signal = resample(signal, len(signal) * upsample_factor)
    new_x = np.linspace(0, n - 1, len(resampled_signal))

    interp_func = interp1d(new_x, resampled_signal, kind='linear', fill_value=0, bounds_error=False)
    return interp_func(delayed_x)


def delay_and_sum(micData, fs, theta_range, phi_range):
    print(f"Data shape before beamforming: {micData.shape}")

    power_map = np.zeros((len(theta_range), len(phi_range)))

    print("Computing beamforming map...")
    for i, theta in enumerate(theta_range):
        if i % 10 == 0:
            print(f"Processing elevation angle {i}/{len(theta_range)}")

        for j, phi in enumerate(phi_range):
            theta_rad = np.radians(theta)
            phi_rad = np.radians(phi)

            delays = compute_delays(theta_rad, phi_rad, fs)
            delayed_signals = np.zeros_like(micData[:, 0], dtype=np.float64)

            for x in range(Nx):
                for y in range(Ny):
                    mic_idx = y * Nx + x
                    # mic_idx = x * Ny + y

                    shifted_signal = apply_delay(micData[:, mic_idx], delays[y, x])
                    delayed_signals += shifted_signal

            # Use RMS instead of variance
            power_map[i, j] = np.sqrt(np.mean(delayed_signals**2))

    print("Normalizing power map...")
    power_map -= power_map.min()
    max_val = power_map.max()
    if max_val > 0:
        power_map /= (max_val + 1e-10)  # Prevent division by zero

    return power_map


# --------------------- main ----------------
# file_name = "recording_combined"
# file_name = "4000Hz_front"
file_name = "4000Hz_right"
# file_name = "drone_front"
# file_name = "drone_right"


ROOT = os.getcwd()
bin_path = Path(ROOT + "/recorded_data/" + f"{file_name}.bin")
# sample_counter, all_data = read_bin_file(bin_path)
sample_counter, subband_nr, all_data = read_bin_file_fpga(bin_path)

all_data = process_data(sample_counter, all_data)


f_sampling = 48828.125/32

# preform beamorming
theta_range = np.linspace(-90, 90, 20)  # Elevation angles
phi_range = np.linspace(-90, 90, 20)    # Azimuth angles

print("Starting beamforming computation...")
power_map = delay_and_sum(all_data, f_sampling, theta_range, phi_range)

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
