import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt
import signal_generator

# General
Fs = 48828.125  # Sampling Rate

# Filter parameters
M = 64  # Number band pass filters
num_taps = M * 4  # Number of taps per filter

# END USER PARAMETERS
####################

def design_polyphase_filterbank(M, num_taps, Fs):
    """Design a polyphase filter bank with shifted bandpass filters."""
    prototype_filter = signal.firwin(num_taps, 1.0 / M, window="hamming")  # Lowpass prototype
    polyphase_filters = []
    center_frequencies = np.linspace(0, Fs / 2, M, endpoint=False)  # Evenly spaced subbands
    n = np.arange(num_taps)
    for f_center in center_frequencies:
        shifted_filter = prototype_filter * np.exp(1j * 2 * np.pi * f_center * n / Fs)  # Frequency shift
        polyphase_filters.append(np.real(shifted_filter))  # Keep only the real part
    return np.array(polyphase_filters), center_frequencies


def apply_polyphase_filterbank(input_signal, polyphase_filters, M):
    """Apply polyphase analysis filter bank."""
    min_length = (len(input_signal) // M) * M  # Ensure equal length segments
    input_signal = input_signal[:min_length]  # Trim signal to multiple of M
    subband_signals = [signal.lfilter(polyphase_filters[m], 1, input_signal) for m in range(M)]
    return np.vstack(subband_signals)  # Ensure a consistent shape


def print_subband_average_amplitude(subband_signals):
    for i in range(len(subband_signals)):
        energy = np.sum(np.abs(subband_signals[i]))
        print(f"Pre-Decimation {i:3} Energy: {energy:12.2f}")


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


# Generate input signal
input_signal = signal_generator.generate_signal()

# Design filter and filter signal
polyphase_filters, center_frequencies = design_polyphase_filterbank(M, num_taps, Fs)
subband_signals = apply_polyphase_filterbank(input_signal, polyphase_filters, M)

# plot result
print_subband_average_amplitude(subband_signals)
plot_freq_components(subband_signals, Fs, M, center_frequencies)
