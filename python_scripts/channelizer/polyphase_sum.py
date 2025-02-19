import numpy as np
import scipy
import matplotlib.pyplot as plt
import signal_generator
import scipy.signal as signal


Fs = 48828.125
num_subbands = 32
M = 16      # Number of taps
P = 32     # Number of 'branches', also fft length
filter_width = Fs / (2 * num_subbands)
num_taps = M * P


def pfb_fir_frontend(x, win_coeffs, M, P):
    W = int(len(x) / M / P)
    x_p = x.reshape((W*M, P)).T
    h_p = win_coeffs.reshape((M, P)).T
    x_summed = np.zeros((P, M * W - M))
    for t in range(0, M*W-M):
        x_window = x_p[:, t:t + M]
        x_weighted = x_window * h_p
        x_summed[:, t] = x_weighted.sum(axis=1)
    return x_summed.T


def design_subband_filters(plt_bool=False):
    """Design a bank of M bandpass filters."""
    filters = []
    center_frequencies = np.linspace(filter_width/2, Fs/2 - filter_width/2, num_subbands, endpoint=True)  # Subband centers

    for center_frequency in center_frequencies:
        low_edge = max(0.1, center_frequency - filter_width/2)
        high_edge = min(Fs / 2 - 0.1, center_frequency + filter_width/2)
        #print(low_edge, high_edge)

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


def fft(x_p, P, axis=1):
    return np.fft.rfft(x_p, P, axis=axis)


def db(x):
    """ Convert linear value to dB value """
    return 10*np.log10(x)


x = signal_generator.generate_signal()
filters_all, center_frequencies = design_subband_filters(plt_bool=True)

subbands = []
for i in range(len(center_frequencies)):
    x_fir = pfb_fir_frontend(x, filters_all[i], M, P)
    x_fir_sum = np.sum(x_fir, axis=1)
    subbands.append(x_fir_sum)

subbands = np.array(subbands)

print(len(x)/num_subbands)
print(subbands.shape)

subbands_power = np.abs(subbands)**2


def db(x):
    return 10*np.log10(x)


plt.imshow(db(subbands_power.T), cmap='viridis', aspect='auto')
plt.colorbar()
plt.xlabel("Channel")
plt.ylabel("Time")
plt.show()
