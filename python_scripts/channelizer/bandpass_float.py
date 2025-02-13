import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt
import signal_generator

######################
# START USER PARAMETERS

# General
Fs = 48828.125  # Sampling Rate

# Filter parameters
Fpass = 80  # Filter Width
M = 32  # Number band pass filters
num_taps = 128  # Number of taps per filter

# END USER PARAMETERS
####################


def design_subband_filters(plt_bool=False):
    """Design a bank of M bandpass filters."""
    filters = []
    center_frequencies = np.linspace(0, Fs / 2, M, endpoint=False)  # Subband centers

    for f in center_frequencies:
        # Clip the band edges to valid range [0, Fs/2]
        low_edge = max(0, f - Fpass)
        high_edge = min(Fs / 2, f + Fpass)

        # Skip invalid bands where low_edge >= high_edge
        if low_edge >= high_edge:
            print(f"Error: Invalid band for center frequency {f:.1f} Hz, skipping filter.")
            continue

        try:
            # Design bandpass filter using firwin
            taps = signal.firwin(num_taps, [low_edge, high_edge], pass_zero=False, fs=Fs)
            filters.append(taps)
        except ValueError as e:
            print(f"Error designing filter for {low_edge}-{high_edge} Hz: {e}")
            continue

    filters = np.array(filters)

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

    return filters


def apply_subband_filters(input_signal, filters, plt_bool=False):
    """Apply a bank of subband filters to an input signal."""
    M = len(filters)
    subband_signals = []

    for i in range(M):
        subband_signal = signal.lfilter(filters[i], 1, input_signal)
        subband_signals.append(subband_signal)

    subband_signals = np.array(subband_signals)

    if plt_bool:
        plt.figure()
        for i in range(M):
            plt.plot(subband_signals[i], label=f"Subband {i}")
        plt.title("Filtered Subband Signals")
        plt.xlabel("Sample")
        plt.ylabel("Amplitude")
        plt.xlim(100)
        plt.legend()
        plt.grid()
        plt.show()

    return subband_signals


def plot_freq_components(subband_signals, Fs):
    """Plot subband signals with frequency on the y-axis and time on the x-axis."""
    M, N = subband_signals.shape  # M = number of subbands, N = number of samples
    time = np.arange(N) / Fs  # Convert samples to time
    freqs = np.linspace(0, Fs / 2, M, endpoint=False)  # Approximate center frequencies

    plt.figure(figsize=(10, 6))
    plt.imshow(subband_signals, aspect="auto", extent=[time[0], time[-1], freqs[0], freqs[-1]],
               origin="lower", cmap="jet")

    plt.colorbar(label="Amplitude")
    plt.xlabel("Time (s)")
    plt.ylabel("Frequency (Hz)")
    plt.title("Subband Signal Amplitudes Over Time")
    plt.grid(False)
    plt.show()


def print_subband_average_amplitude(subband_signals):
    for i in range(len(subband_signals)):
        print(f"Subband {i} average amplitude: {np.mean(np.abs(subband_signals[i]))}")


# Main
input_signal = signal_generator.generate_signal()

filters = design_subband_filters(plt_bool=True)
subband_signals = apply_subband_filters(input_signal, filters, plt_bool=False)
plot_freq_components(subband_signals, Fs)
print_subband_average_amplitude(subband_signals)
