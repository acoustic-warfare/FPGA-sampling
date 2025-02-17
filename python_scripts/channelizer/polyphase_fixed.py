import numpy as np
from scipy.signal import lfilter
from scipy.signal import firwin
from scipy.signal import freqz
import matplotlib.pyplot as plt
import signal_generator

######################
# START USER PARAMETERS

# General
Fs = 48828.125  # Sampling Rate

# Filter parameters
M = 8  # Number band pass filters
nr_taps = M * 16  # Number of taps per filter

# END USER PARAMETERS
####################

bandwidth = Fs / (2 * M)
center_frequencies = np.arange(bandwidth / 2, Fs / 2, bandwidth)
print(bandwidth)
print(center_frequencies)
print("frequency i want to use: ", center_frequencies[0])
filter_width = bandwidth  # Filter Width


class PolyphaseDecimator:
    def __init__(self, filter_coeffs, decimation_factor):
        self.M = decimation_factor
        self.phases = [filter_coeffs[i::self.M] for i in range(self.M)]

    def decimate(self, x):
        # Apply each phase of the filter and downsample
        filtered_outputs = [lfilter(phase, 1, x) for phase in self.phases]
        # Combine the phases based on the decimation factor
        y = np.zeros(len(x) // self.M)
        for i in range(self.M):
            y += filtered_outputs[i][i::self.M][:len(y)]
        return y


def gen_filter_coeffs(center_frequency, filter_width, nr_taps, Fs):
    low_cutoff = max(0.1, center_frequency - filter_width / 2)  # 0.1 to avoid: ValueError: Invalid cutoff frequency: 0, fs/2.
    high_cutoff = min(Fs / 2 - 0.1, center_frequency + filter_width / 2)

    print("low_cutoff", low_cutoff)
    print("high_cutoff", high_cutoff)

    filter_coeffs = firwin(nr_taps, [low_cutoff, high_cutoff], pass_zero=False, fs=Fs)
    return filter_coeffs


def plot_filter_frequency_all_response(all_filter_coeffs, Fs):
    plt.figure(figsize=(10, 6))  # Adjust figure size for better visualization

    for i, filter_coeffs in enumerate(all_filter_coeffs):
        # Calculate the frequency response for each filter
        w, h = freqz(filter_coeffs, 1, worN=8192)

        # Convert frequencies to Hz
        frequencies = (w / (2 * np.pi)) * Fs

        # Plot the frequency response in dB, add a label for each filter
        plt.plot(frequencies, 20 * np.log10(np.abs(h)), label=f'Filter {i+1}')  # Add label

    plt.title('Frequency Response of Multiple Filters (dB)')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Magnitude (dB)')
    plt.grid(True)
    #plt.semilogx()  # Use log scale for frequency axis
    plt.xlim(20, Fs / 2)  # Limit x-axis to positive frequencies up to Nyquist, start at 20Hz
    plt.ylim(-60, 5)  # Set reasonable limits for dB plot
    plt.legend()  # Show the legend to distinguish filters
    plt.tight_layout()  # Adjust layout to prevent labels from overlapping
    plt.show()


all_filter_coeffs = []
for i in range(M):
    filter_coeffs = gen_filter_coeffs(center_frequencies[i], filter_width, nr_taps, Fs)
    all_filter_coeffs.append(filter_coeffs)
plot_filter_frequency_all_response(all_filter_coeffs, Fs)

# Create a decimator with decimation factor of 4
decimator = PolyphaseDecimator(filter_coeffs, decimation_factor=M)

# Generate input signal
input_signal = signal_generator.generate_signal()

# Decimate the signal
decimated_signal = decimator.decimate(input_signal)

# Output result
print("Original Signal Length:", len(input_signal))
print("Decimated Signal Length:", len(decimated_signal))


def plot_signals(original_signal, decimated_signal):
    # Time domain plot
    plt.figure(figsize=(12, 6))
    plt.subplot(4, 1, 1)
    plt.plot(original_signal[:1000], label="Original Signal (First 1000 samples)")
    plt.title("Original Signal (Time Domain)")
    plt.xlabel("Samples")
    plt.ylabel("Amplitude")
    plt.legend()

    plt.subplot(4, 1, 2)
    plt.plot(decimated_signal[:int(np.floor(1000 / M))], label="Decimated Signal (First 1000 samples)")
    plt.title("Decimated Signal (Time Domain)")
    plt.xlabel("Samples")
    plt.ylabel("Amplitude")
    plt.legend()

    # Frequency domain plot (FFT)
    N_orig = len(original_signal)
    yf_orig = np.fft.fft(original_signal)
    xf_orig = np.fft.fftfreq(N_orig, 1/Fs)[:N_orig//2]  # Only positive frequencies

    N_dec = len(decimated_signal)
    yf_dec = np.fft.fft(decimated_signal)
    xf_dec = np.fft.fftfreq(N_dec, 1/(Fs/M))[:N_dec//2]  # Adjusted Fs for decimated signal

    # plt.figure(figsize=(12, 6))
    plt.subplot(4, 1, 3)
    plt.plot(xf_orig, np.abs(yf_orig[:N_orig//2]), label="Original Signal FFT")
    plt.title("Original Signal (Frequency Domain)")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude")
    plt.legend()

    plt.subplot(4, 1, 4)
    plt.plot(xf_dec, np.abs(yf_dec[:N_dec//2]), label="Decimated Signal FFT")
    plt.title("Decimated Signal (Frequency Domain)")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude")
    plt.legend()
    plt.tight_layout()
    plt.show()


plot_signals(input_signal, decimated_signal)
