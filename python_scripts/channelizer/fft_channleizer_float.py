import numpy as np
import scipy.signal as sp_signal
import matplotlib.pyplot as plt
import signal_generator

######################
# START USER PARAMETERS

# General
Fs = 48828.125  # Sampling Rate

# Filter parameters
M = 64  # Number of channels (subbands)
Fpass = Fs / (2 * M)  # Passband edge of prototype filter (low-pass)
num_taps = M * 4  # Increased number of taps for better filter sharpness
num_taps = (num_taps // M) * M  # Ensures it's a multiple of M

# END USER PARAMETERS
####################


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


# Main
input_signal = signal_generator.generate_signal()

# Apply FFT Channelizer
subband_signals, freq_bins = fft_channelizer(input_signal, M, Fs)

# Plot the spectrogram
plot_spectrum(subband_signals, freq_bins)
