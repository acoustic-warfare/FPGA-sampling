import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt

# Define your parameters


######################
# START USER PARAMETERS

# General
Fs = 48828.125  # Sampling Rate

# Filter parameters
Fpass = 80  # Filter Width
M = 32  # Number band pass filters
num_taps = 128  # Number of taps per filter

# Input signal
frequencies = [1000, 10000, 20000]
amplitudes = [100, 100, 100]
length = 100000  # Number of samples

# Noise parameters
SNR_dB = 10  # Desired Signal-to-Noise Ratio in dB

# END USER PARAMETERS
####################


def gen_signal():
    """Generate a multi-tone signal."""
    t = np.arange(length) / Fs  # Time vector
    input_signal = np.sum([amplitudes[i] * np.sin(2 * np.pi * f * t) for i, f in enumerate(frequencies)], axis=0)

    return input_signal


def add_noise(input_signal):
    """Add white Gaussian noise to the input signal based on a given SNR."""
    signal_power = np.mean(input_signal**2)  # Compute signal power
    noise_power = signal_power / (10**(SNR_dB / 10))  # Compute noise power based on SNR
    noise = np.sqrt(noise_power) * np.random.randn(len(input_signal))  # Generate white Gaussian noise
    input_signal_with_noise = input_signal + noise  # Add noise to the signal

    return input_signal_with_noise


def plot_signals(signal_0, signal_1, Fs):
    """Compute and plot the FFT of two signals in separate subplots."""
    N = len(signal_0)  # Assume both signals have the same length
    freq_axis = np.fft.fftfreq(N, d=1/Fs)[:N//2]  # Compute positive frequencies

    # Compute FFT magnitude (normalize for comparison)
    fft_0 = np.fft.fft(signal_0)
    fft_1 = np.fft.fft(signal_1)
    magnitude_0 = 20 * np.log10(np.abs(fft_0[:N//2]) + 1e-12)  # Avoid log(0)
    magnitude_1 = 20 * np.log10(np.abs(fft_1[:N//2]) + 1e-12)

    # Create subplots
    plt.figure(figsize=(10, 6))

    # Plot FFT of signal_0
    plt.subplot(2, 1, 1)
    plt.plot(freq_axis, magnitude_0, color="b")
    plt.ylabel("Magnitude (dB)")
    plt.grid()

    # Plot FFT of signal_1
    plt.subplot(2, 1, 2)
    plt.plot(freq_axis, magnitude_1, color="r")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude (dB)")
    plt.grid()

    plt.tight_layout()
    plt.show()


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


# Example usage
input_signal = gen_signal()
input_signal_no_noise = input_signal
input_signal = add_noise(input_signal)
plot_signals(input_signal_no_noise, input_signal, Fs=Fs)

filters = design_subband_filters(plt_bool=True)  # Plot filter responses
subband_signals = apply_subband_filters(input_signal, filters, plt_bool=False)  # Plot filtered signals
plot_freq_components(subband_signals, Fs)
