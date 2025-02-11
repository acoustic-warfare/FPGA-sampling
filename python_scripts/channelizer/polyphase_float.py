import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt

######################
# START USER PARAMETERS

# General
Fs = 48828.125  # Sampling Rate

# Filter parameters
M = 32  # Number of channels (750 Hz resolution per bin)
Fpass = Fs / (2 * M) * 0.9  # Passband edge of prototype filter (low-pass)
num_taps = 4 * M  # Increase the order for better filtering
num_taps = (num_taps // M) * M  # Ensures it's a multiple of M
print(f"Prototype filter taps: {num_taps}")

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


def filter_setup(plt_bool=False):
    """Design a low-pass FIR prototype filter and reshape into polyphase components."""
    prototype_filter = signal.firwin(num_taps, Fpass, fs=Fs, window="hamming")

    # Plot frequency response of the prototype filter
    if plt_bool:
        w, h = signal.freqz(prototype_filter, worN=1024, fs=Fs)
        plt.figure()
        plt.plot(w, 20 * np.log10(abs(h) + 1e-12))  # Avoid log(0) issues
        plt.title("Prototype Low-Pass Filter Response")
        plt.xlabel("Frequency (Hz)")
        plt.ylabel("Magnitude (dB)")
        plt.grid()
        plt.show()

    # Reshape into polyphase filters
    polyphase_filters = prototype_filter.reshape((M, -1), order='F')
    return polyphase_filters


def polyphase_channelizer(input_signal, polyphase_filters, M, plt_bool=False):
    """Perform polyphase filtering and FFT-based channelization."""
    num_blocks = len(input_signal) // M
    input_signal = input_signal[:num_blocks * M]  # Trim input to fit polyphase structure

    # Reshape into M parallel streams
    input_blocks = input_signal.reshape((num_blocks, M))

    # Apply polyphase filtering
    filtered_blocks = np.zeros((num_blocks, M))
    for i in range(M):
        filtered_blocks[:, i] = signal.lfilter(polyphase_filters[i], 1, input_blocks[:, i])

    # Plot one channel's filtered output for visualization
    if plt_bool:
        plt.figure()
        plt.plot(filtered_blocks[200:400, 0])
        plt.title("First Polyphase Output (Filtered)")
        plt.xlabel("Samples")
        plt.ylabel("Amplitude")
        plt.grid()
        plt.show()

    # FFT to extract frequency channels
    fft_output = np.fft.fft(filtered_blocks, axis=1)

    return fft_output


def plot_spectrum(fft_output):
    """Plot the final FFT magnitude spectrum with frequency labels on Y-axis and time in seconds on X-axis."""
    magnitude_spectrum = 20 * np.log10(abs(fft_output.T) + 1e-12)  # Avoid log(0) issues

    # Generate frequency axis (only positive frequencies for real-valued signals)
    freq_axis = np.fft.fftfreq(M, d=1/Fs)[:M//2]  # Only keep positive frequencies

    # Convert x-axis from blocks to time (s)
    time_axis_end = magnitude_spectrum.shape[1] * (M / Fs)

    plt.figure()
    plt.imshow(magnitude_spectrum[:M//2, :], aspect='auto', origin='lower', cmap='jet',
               extent=[0, time_axis_end, freq_axis[0], freq_axis[-1]])
    plt.ylabel("Frequency (Hz)")
    plt.xlabel("Time (s)")
    plt.colorbar(label="Magnitude (dB)")
    plt.title("Polyphase Channelizer Output (FFT Magnitude)")
    plt.show()


# Run simulation step by step
input_signal = gen_signal()
input_signal_no_noise = input_signal
input_signal = add_noise(input_signal)
plot_signals(input_signal_no_noise, input_signal, Fs=Fs)

polyphase_filters = filter_setup(plt_bool=True)
fft_output = polyphase_channelizer(input_signal, polyphase_filters, M)
plot_spectrum(fft_output)
