from scipy.signal import hilbert
import os
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate


def read_bin_file_fpga(bin_path):
    data = np.fromfile(bin_path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 68)  # Each row: 4 header fields + 64 mic data values
    sample_counter = data2D[:, 2]
    sample_counter = (sample_counter - sample_counter[0])/32
    subband_nr = data2D[:, 3]
    micData = data2D[:, 4:]
    return sample_counter, subband_nr, micData


def extract_subband_data(sample_counter, subband_nr, micData, target_subbands):
    """
    Extract data for specific subbands.

    Args:
        sample_counter: Sample counter values
        subband_nr: Subband numbers
        micData: Microphone data
        target_subbands: List of subband numbers to extract

    Returns:
        Dictionary with subband data for each target subband
    """
    subband_data = {}

    for subband in target_subbands:
        # Find indices where subband_nr matches the target subband
        indices = np.where(subband_nr == subband)[0]

        if len(indices) == 0:
            print(f"Subband {subband} not found in data")
            continue

        # Extract data for this subband
        subband_sample_counter = sample_counter[indices]
        subband_mic_data = micData[indices, :]

        # Process and interpolate the subband data
        processed_data = process_subband_data(subband_sample_counter, subband_mic_data)

        subband_data[subband] = processed_data

    return subband_data


def process_subband_data(sample_counter, micData):
    """
    Process subband data by handling duplicate sample counters and interpolating missing samples.
    """
    unique_counters = np.unique(sample_counter)
    processed_data = np.zeros((len(unique_counters), micData.shape[1]))

    for i, counter in enumerate(unique_counters):
        indices = np.where(sample_counter == counter)[0]
        processed_data[i, :] = np.mean(micData[indices, :], axis=0)  # Use mean instead of sum

    # Interpolate missing samples
    full_range = np.arange(unique_counters[0], unique_counters[-1] + 1)
    interpolated_data = np.zeros((len(full_range), micData.shape[1]))

    for mic in range(micData.shape[1]):
        f = interpolate.interp1d(unique_counters, processed_data[:, mic], kind='linear', fill_value='extrapolate')
        interpolated_data[:, mic] = f(full_range)

    return interpolated_data


# Constants
c = 343  # Speed of sound in air (m/s)
d = 0.02  # Distance between microphones (m) - 2 cm between the elements
Nx, Ny = 8, 8  # 8x8 microphone array
fs_subband = 48828.125/32  # Subband sampling rate (Hz)
subband_width = 48828.125/64  # Hz


def create_mic_positions():
    """
    Create an array of microphone positions for the 8x8 array.
    Returns positions with proper indexing.
    """
    # Create microphone positions in 3D space (x, y, z)
    mic_positions = np.zeros((Nx * Ny, 3))
    mic_indices = np.zeros((Nx, Ny), dtype=int)  # To keep track of flattened indices

    idx = 0
    for y in range(Ny):
        for x in range(Nx):
            # Convert from array indices to physical coordinates
            # With origin (0,0,0) at center of array
            dx = (x - (Nx - 1) / 2) * d  # x increases from left to right
            dy = ((Ny - 1) / 2 - y) * d  # y increases from bottom to top
            mic_positions[idx] = [dx, dy, 0]  # z=0 for planar array
            mic_indices[y, x] = idx
            idx += 1

    return mic_positions, mic_indices


def compute_phase_shifts(theta, phi, subband_index, mic_positions):
    """
    Compute phase shifts with improved accuracy.
    """
    # Calculate center frequency of the subband
    center_freq = (subband_index + 0.5) * subband_width
    wavelength = c / center_freq

    # Direction vector calculation
    doa = np.array([
        np.cos(theta) * np.sin(phi),    # x component
        np.sin(theta),                  # y component
        np.cos(theta) * np.cos(phi)     # z component
    ])

    # Normalize direction vector
    doa = doa / np.linalg.norm(doa)

    # Calculate phase shifts with improved precision
    phase_shifts = np.zeros(len(mic_positions), dtype=np.complex128)

    for i in range(len(mic_positions)):
        # Calculate exact path length difference
        projection = np.dot(mic_positions[i], doa)

        # More precise phase calculation
        phase = -2 * np.pi * projection / wavelength

        # Apply phase shift
        phase_shifts[i] = np.exp(1j * phase)

    return phase_shifts


def process_to_analytic_signal(subband_data):
    """
    Convert real-valued subband data to proper analytic signal
    using Hilbert transform.
    """
    analytic_data = np.zeros_like(subband_data, dtype=np.complex128)

    for mic in range(subband_data.shape[1]):
        analytic_data[:, mic] = hilbert(subband_data[:, mic])

    return analytic_data


def subband_beamforming(subband_data, subband_index, theta_range, phi_range):
    """
    Perform beamforming in the subband domain with corrected phase calculations.

    Args:
        subband_data: Processed data for a specific subband
        subband_index: Index of the subband
        theta_range: Range of elevation angles
        phi_range: Range of azimuth angles

    Returns:
        Power map
    """
    print(f"Performing beamforming for subband {subband_index}")
    print(f"Data shape for subband {subband_index}: {subband_data.shape}")

    power_map = np.zeros((len(theta_range), len(phi_range)))

    # Create microphone positions
    mic_positions, mic_indices = create_mic_positions()

    # Convert real data to analytic signal (with proper phase information)
    analytic_data = process_to_analytic_signal(subband_data)

    # Apply spatial windowing to reduce sidelobes
    # Using a raised cosine (Hann) window across the array
    y_window = np.hanning(Ny)
    x_window = np.hanning(Nx)
    spatial_window = np.outer(y_window, x_window).flatten()

    print("Computing beamforming map...")
    for i, theta in enumerate(theta_range):
        if i % 5 == 0:
            print(f"Processing elevation angle {i}/{len(theta_range)}")

        for j, phi in enumerate(phi_range):
            theta_rad = np.radians(theta)
            phi_rad = np.radians(phi)

            # Compute phase shifts for this direction
            phase_shifts = compute_phase_shifts(theta_rad, phi_rad, subband_index, mic_positions)

            # Apply spatial window to reduce sidelobes
            weighted_phase_shifts = phase_shifts * spatial_window

            # Initialize output signal
            beamformed_signal = np.zeros(analytic_data.shape[0], dtype=np.complex128)

            # Apply phase shifts and sum
            for mic_idx in range(Nx * Ny):
                # Apply phase shift to microphone signal and add to output
                beamformed_signal += analytic_data[:, mic_idx] * weighted_phase_shifts[mic_idx]

            # Calculate power (magnitude squared of complex signal)
            power_map[i, j] = np.mean(np.abs(beamformed_signal) ** 2)

    # Normalize power map
    power_map -= power_map.min()
    max_val = power_map.max()
    if max_val > 0:
        power_map /= (max_val + 1e-10)  # Prevent division by zero

    return power_map


def plot_beamforming_result(power_map, title, output_file=None):
    """
    Plot beamforming result with improved visualization.
    """
    plt.figure(figsize=(10, 8))

    # Use a logarithmic scale for better visualization
    power_map_db = 10 * np.log10(power_map + 1e-10)  # Avoid log of zero

    # Clip values to improve contrast (dynamic range compression)
    vmin = np.max([power_map_db.max() - 20, power_map_db.min()])

    # Create the heatmap
    im = plt.imshow(power_map_db, extent=[-90, 90, -90, 90], origin='lower',
                    aspect='auto', cmap='jet', vmin=vmin)

    # Add colorbar
    cbar = plt.colorbar(im, label='Power (dB)')

    # Add labels and grid
    plt.xlabel('Azimuth Angle (degrees)')
    plt.ylabel('Elevation Angle (degrees)')
    plt.title(title)
    plt.grid(True, linestyle='--', alpha=0.6)

    # Add markers for expected directions (if known)
    if "right" in title.lower():
        plt.scatter([90], [0], marker='x', color='white', s=100, label='Expected (Right)')
    elif "front" in title.lower():
        plt.scatter([0], [0], marker='x', color='white', s=100, label='Expected (Front)')

    # Add coordinate system diagram to show orientation
    ax = plt.gca()
    # Add small coordinate system diagram
    ax_inset = plt.axes([0.15, 0.15, 0.2, 0.2])
    ax_inset.set_xlim(-0.1, 0.9)
    ax_inset.set_ylim(-0.1, 0.9)
    # Draw coordinate system
    ax_inset.arrow(0, 0, 0.7, 0, head_width=0.1, head_length=0.1, fc='r', ec='r')
    ax_inset.arrow(0, 0, 0, 0.7, head_width=0.1, head_length=0.1, fc='g', ec='g')
    ax_inset.arrow(0, 0, 0.45, 0.45, head_width=0.1, head_length=0.1, fc='b', ec='b')
    ax_inset.text(0.5, 0.1, "x (right)", color='r', va='center')
    ax_inset.text(0.2, 0.7, "y (up)", color='g', ha='center')
    ax_inset.text(0.4, 0.55, "z (front)", color='b')
    ax_inset.set_xticks([])
    ax_inset.set_yticks([])

    # Save or show
    if output_file:
        plt.savefig(output_file, dpi=300)
    else:
        plt.show()


# Main execution
if __name__ == "__main__":
    # file_name = "recording_combined"
    # file_name = "4000Hz_front"
    # file_name = "4000Hz_right"
    # file_name = "drone_front"
    file_name = "drone_right"

    ROOT = os.getcwd()
    bin_path = Path(ROOT + "/recorded_data/" + f"{file_name}.bin")
    sample_counter, subband_nr, all_data = read_bin_file_fpga(bin_path)

    # Target subbands for processing (focus on subbands 4-5 as requested)
    # target_subbands = [4, 5]
    target_subbands = [2, 3, 4, 5, 6, 7]
    # target_subbands = [10, 11, 12, 13, 14, 15, 16, 17, 18]
    # target_subbands = [3, 4, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]

    # Extract data for target subbands
    subband_data = extract_subband_data(sample_counter, subband_nr, all_data, target_subbands)

    # Define angle ranges with sufficient resolution
    # Increase resolution for better accuracy
    theta_range = np.linspace(-90, 90, 45)  # Elevation angles
    phi_range = np.linspace(-90, 90, 45)    # Azimuth angles

    # Perform beamforming on each subband and combine results
    combined_power_map = np.zeros((len(theta_range), len(phi_range)))
    processed_subbands = []

    for subband_idx in target_subbands:
        if subband_idx in subband_data:
            print(f"\nProcessing subband {subband_idx}")
            processed_subbands.append(subband_idx)

            # Perform beamforming
            power_map = subband_beamforming(subband_data[subband_idx], subband_idx, theta_range, phi_range)

            # Plot individual subband result
            plot_beamforming_result(power_map, f"Beamforming Result - Subband {subband_idx}", f"beamforming_subband_{subband_idx}.png")

            # Add to combined map
            combined_power_map += power_map
        else:
            print(f"No data available for subband {subband_idx}")

    # Normalize combined power map
    if len(processed_subbands) > 1:
        combined_power_map /= len(processed_subbands)

        # Apply non-linear enhancement for better contrast
        combined_power_map = combined_power_map ** 4

        # Plot combined result
        plot_beamforming_result(combined_power_map, f"Combined Beamforming Result - Subbands {processed_subbands}", f"beamforming_combined_subbands.png")
