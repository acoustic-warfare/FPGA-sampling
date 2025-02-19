import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt
import signal_generator

######################
# START USER PARAMETERS

# General
Fs = 48828.125  # Sampling Rate

# Filter parameters
M = 32  # Number band pass filters
num_taps = 16*32  # Number of taps per filter
filter_width = Fs / (2 * M)
# END USER PARAMETERS
####################


def design_subband_filters(plt_bool=False):
    """Design a bank of M bandpass filters."""
    filters = []
    center_frequencies = np.linspace(0, Fs / 2, M, endpoint=False)  # Subband centers
    for center_frequency in center_frequencies:
        low_edge = max(0.1, center_frequency - filter_width/2)
        high_edge = min(Fs - 0.1 / 2, center_frequency + filter_width/2)
        # print(low_edge, high_edge)

        taps = signal.firwin(num_taps, [low_edge, high_edge], fs=Fs, pass_zero=False)
        filters.append(taps)

    filters = np.array(filters)

    if plt_bool:
        plt.figure()
        for i in range(0, len(filters)):  # Plot a subset of filters
            w, h = signal.freqz(filters[i], worN=1024, fs=Fs)
            plt.plot(w, 20 * np.log10(abs(h) + 1e-12), label=f"Filter {i} ({center_frequencies[i]:.1f} Hz)")
        plt.show()

    return filters, center_frequencies


def apply_subband_filters(input_signal, filters):
    """Apply a bank of subband filters to an input signal."""
    subband_signals = []
    for i in range(M):
        subband_signal = signal.lfilter(filters[i], 1, input_signal)
        subband_signals.append(subband_signal)

    return np.array(subband_signals)


def apply_down_sampling(subband_signals):
    downsampled_subbands = []
    for subband in subband_signals:
        downsampled_signal = subband[::M]
        downsampled_subbands.append(downsampled_signal)

    return np.array(downsampled_subbands)


# Generate input signal
input_signal = signal_generator.generate_signal()
print("input length: ", len(input_signal))

# Create filter and run signalr through filters
filters, center_frequencies = design_subband_filters(plt_bool=True)
subband_signals = apply_subband_filters(input_signal, filters)

downsampled_subbands = apply_down_sampling(subband_signals)
print("output length:", len(downsampled_subbands[0]))

# take the power from the downsampled signal
downsampled_subbands_power = np.abs(downsampled_subbands)**2


def db(x):
    return 10*np.log10(x)


plt.imshow(db(downsampled_subbands_power.T), cmap='viridis', aspect='auto')
plt.colorbar()
plt.xlabel("Channel")
plt.ylabel("Time")
plt.show()
