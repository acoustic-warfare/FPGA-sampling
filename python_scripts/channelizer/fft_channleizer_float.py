import numpy as np
import scipy.signal as sp_signal
import matplotlib.pyplot as plt

######################
# START USER PARAMETERS

# General
Fs = 48828.125  # Sampling Rate

# Filter parameters
M = 128  # Number of channels (subbands)
Fpass = Fs / (2 * M)  # Passband edge of prototype filter (low-pass)
num_taps = M * 8  # Increased number of taps for better filter sharpness
num_taps = (num_taps // M) * M  # Ensures it's a multiple of M

# Input signal
frequencies = [1000, 10000, 20000]
amplitudes = [100, 100, 100]
length = 50000  # Number of samples

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


def fft_channelizer(input_signal, M, Fs):
    """Apply FFT-based channelizer to divide the input signal into multiple subbands."""
    N = len(input_signal)  # Number of samples in the signal
    subbands = []

    # Define the frequency bins for each subband
    freq_bins = np.fft.fftfreq(N, d=1/Fs)[:N//2]  # Only keep positive frequencies
    subband_length = N // M  # Length of each subband
    nyquist = 0.5 * Fs  # Nyquist frequency

    # Apply filters (Bandpass) for each subband
    for m in range(M):
        # Define frequency range for the m-th subband
        low_freq = m * (Fs / M)  # Low edge of subband
        high_freq = (m + 1) * (Fs / M)  # High edge of subband
        
        # Ensure that high_freq does not exceed Nyquist
        high_freq = min(high_freq, nyquist)

        # Create a bandpass filter for the subband
        if high_freq > low_freq:  # Only proceed if the subband range is valid
            low = low_freq / nyquist
            high = high_freq / nyquist

            # Filter the signal to extract the desired subband
            try:
                b, a = sp_signal.butter(4, [low, high], btype='bandpass')  # 4th-order Butterworth bandpass filter
                filtered_signal = sp_signal.filtfilt(b, a, input_signal)
                subbands.append(filtered_signal)
            except ValueError as e:
                print(f"Skipping filter for subband {m}: {e}")
                continue

    return np.array(subbands), freq_bins


def plot_spectrum(fft_output, freq_bins):
    """Plot the final FFT magnitude spectrum with frequency labels on Y-axis and time in seconds on X-axis."""
    magnitude_spectrum = 20 * np.log10(abs(fft_output) + 1e-12)  # Avoid log(0 issues)

    # Convert x-axis from blocks to time (s)
    time_axis_end = magnitude_spectrum.shape[1] * (M / Fs)

    # Plot the spectrogram
    plt.figure(figsize=(12, 8))
    plt.imshow(magnitude_spectrum[:M//2, :], aspect='auto', origin='lower', cmap='jet',
               extent=[0, time_axis_end, freq_bins[0], freq_bins[-1]])
    plt.ylabel("Frequency (Hz)")
    plt.xlabel("Time (s)")
    plt.colorbar(label="Magnitude (dB)")
    plt.title("Spectrogram of Channelized Signal")
    plt.show()


# Run simulation step by step
input_signal = gen_signal()
input_signal_no_noise = input_signal
input_signal = add_noise(input_signal)
plot_signals(input_signal_no_noise, input_signal, Fs=Fs)

# Apply FFT Channelizer
subband_signals, freq_bins = fft_channelizer(input_signal, M, Fs)

# Plot the spectrogram
plot_spectrum(subband_signals, freq_bins)
