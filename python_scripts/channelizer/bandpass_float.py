import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt
import signal_generator

######################
# START USER PARAMETERS

# General
Fs = 48828.125  # Sampling Rate

# Filter parameters
Fpass = 100  # Filter Width
M = 64  # Number band pass filters
num_taps = M * 2  # Number of taps per filter

# Noise parameters
SNR_dB = 20  # Desired Signal-to-Noise Ratio in dB

# END USER PARAMETERS
####################


def design_subband_filters(plt_bool=False):
    """Design a bank of M bandpass filters."""
    filters = []
    center_frequencies = np.linspace(0, Fs / 2, M, endpoint=False)  # Subband centers
    center_frequencies_used = []
    for f in center_frequencies:
        # Clip the band edges to valid range [0, Fs/2]
        low_edge = max(0.1, f - Fpass)
        high_edge = min(Fs / 2 - 0.1, f + Fpass)

        # Skip invalid bands where low_edge >= high_edge
        if low_edge >= high_edge:
            print(f"Error: Invalid band for center frequency {f:.1f} Hz, skipping filter.")
            continue

        try:
            # Design bandpass filter using firwin
            # taps = signal.firwin(num_taps, [low_edge, high_edge], pass_zero=False, fs=Fs) # gives more or less the same result
            taps = signal.firwin(num_taps, [low_edge / (Fs / 2), high_edge / (Fs / 2)], pass_zero=False)

            filters.append(taps)
            center_frequencies_used.append(f)
        except ValueError as e:
            print(f"Error designing filter for {low_edge}-{high_edge} Hz: {e}")
            continue

    filters = np.array(filters)
    center_frequencies_used = np.array(center_frequencies_used)

    if plt_bool:
        plt.figure()
        for i in range(0, len(filters)):  # Plot a subset of filters
            w, h = signal.freqz(filters[i], worN=1024, fs=Fs)
            plt.plot(w, 20 * np.log10(abs(h) + 1e-12), label=f"Filter {i} ({center_frequencies[i]:.1f} Hz)")
        plt.title("Subband Filter Bank Frequency Response")
        plt.xlabel("Frequency (Hz)")
        plt.ylabel("Magnitude (dB)")
        plt.legend()
        plt.grid()
        plt.show()

    return filters, center_frequencies_used


def apply_subband_filters(input_signal, filters):
    """Apply a bank of subband filters to an input signal."""
    M = len(filters)
    subband_signals = []

    for i in range(M):
        subband_signal = signal.lfilter(filters[i], 1, input_signal)
        subband_signals.append(subband_signal)

    return np.array(subband_signals)


def apply_decimation(subband_signals, M, center_frequencies):
    """Shift subbands to baseband, low-pass filter, and downsample."""
    decimated_subbands = []
    n = np.arange(subband_signals.shape[1])  # Time index for mixing

    for subband, f_center in zip(subband_signals, center_frequencies):
        # Shift signal to baseband (complex multiplication)
        baseband_signal = subband * np.exp(-1j * 2 * np.pi * f_center * n / Fs)

        # Design a milder low-pass filter
        lp_filter = signal.firwin(63, 0.8 / M, window="hamming")
        filtered_signal = signal.lfilter(lp_filter, 1, baseband_signal)

        # Downsample manually
        decimated_signal = filtered_signal[::M]

        decimated_subbands.append(decimated_signal)

    return np.array(decimated_subbands)


def plot_freq_components(subband_signals, Fs, M, center_frequencies):
    """Plot subband signals with frequency and bin number on the y-axis, and time on the x-axis."""
    N_decimated = subband_signals.shape[1]
    time = np.arange(N_decimated) / (Fs / M)

    plt.figure(figsize=(10, 6))
    y_axis_min = 0
    y_axis_max = len(center_frequencies)

    plt.imshow(np.abs(subband_signals), aspect="auto",
               extent=[time[0], time[-1], y_axis_min, y_axis_max],
               origin="lower", cmap="jet")

    plt.colorbar(label="Amplitude")
    plt.xlabel("Time (s)")

    bin = np.arange(len(center_frequencies)) + 0.5
    plt.yticks(bin, [f"{freq:.0f} Hz" for freq in center_frequencies])
    plt.ylim(y_axis_min, y_axis_max)
    plt.ylabel("Frequency (Hz)")

    ax2 = plt.gca().twinx()
    ax2.set_ylabel("Bin")
    ax2.set_yticks(bin)
    ax2.set_yticklabels([str(i) for i in range(len(center_frequencies))])
    ax2.set_ylim(y_axis_min, y_axis_max)

    plt.show()


def plot_freq_components_subplots(subband_signals, Fs, M):
    """Plot frequency components of the subband signals."""
    N_decimated = subband_signals.shape[1]
    f_res = Fs / (2 * M * N_decimated)  # Frequency resolution
    f_axis = np.arange(N_decimated) * f_res

    plt.figure(figsize=(12, 8))
    for i in range(len(subband_signals)):
        plt.subplot(M // 4, 4, i + 1)  # Create subplots for each subband
        spectrum = np.fft.fft(subband_signals[i])
        spectrum = np.fft.fftshift(spectrum)
        f_axis_plot = np.fft.fftshift(f_axis) - f_res * N_decimated // 2
        plt.plot(f_axis_plot, np.abs(spectrum))
        plt.title(f"Subband {i}")
        plt.xlabel("Frequency (Hz)")
        plt.ylabel("Magnitude")
        plt.xlim([-Fs/(2*M), Fs/(2*M)])  # Set x-axis limits for each subband
    plt.tight_layout()
    plt.show()


def print_subband_average_amplitude(subband_signals, decimated_subbands):
    for i in range(len(subband_signals)):
        pre_energy = np.sum(np.abs(subband_signals[i]))
        post_energy = np.sum(np.abs(decimated_subbands[i]))
        print(f"Pre-Decimation {i:3} Energy: {pre_energy:12.2f}     Post-Decimation {i:3} Energy: {post_energy:12.2f}")


# Generate input signal
input_signal = signal_generator.generate_signal()

# Create filter and run signalr through filters
filters, center_frequencies = design_subband_filters(plt_bool=True)
subband_signals = apply_subband_filters(input_signal, filters)
decimated_subbands = apply_decimation(subband_signals, M, center_frequencies)

# Plot and print result
plot_freq_components(decimated_subbands, Fs, M, center_frequencies)
# plot_freq_components_subplots(subband_signals, Fs, M)
print_subband_average_amplitude(subband_signals, decimated_subbands)
