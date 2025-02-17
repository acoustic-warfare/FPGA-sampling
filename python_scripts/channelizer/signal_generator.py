import numpy as np
import matplotlib.pyplot as plt

######################
# START USER PARAMETERS

# General
Fs = 48828.125  # Sampling Rate

# Input signal
frequencies = [1300, 10000, 20000]
amplitudes = [100, 100, 100]
length = 100000  # Number of samples

# Add tone after set time
add_frequencies = [5000, 15000]
add_amplitudes = [100, 20]
start_time = [20000, 50000]
end_time = [40000, 100000]

# Add chirp
chirp_min_frequency = 2000
chirp_max_frequency = 7000
chirp_amplitude = 50
chirp_length = 10000

# Noise parameters
SNR_dB = 20  # Desired Signal-to-Noise Ratio in dB

# END USER PARAMETERS
####################


def generate_signal(long_tone=True, shot_tone=True, chirp=True, noise=True, plt=True):
    input_signal = np.zeros(length)
    sig_no_noise = np.zeros(length)

    if long_tone:
        input_signal = _add_long_tone(input_signal)
        sig_no_noise = _add_long_tone(sig_no_noise)
    if shot_tone:
        input_signal = _add_short_tone(input_signal)
        sig_no_noise = _add_short_tone(sig_no_noise)
    if chirp:
        input_signal = _add_chirp(input_signal)
        sig_no_noise = _add_chirp(sig_no_noise)
    if noise:
        input_signal = _add_noise(input_signal)

    if plt:
        _plot_input_signals(sig_no_noise, input_signal)

    return input_signal


def _add_long_tone(input_signal):
    t = np.arange(length) / Fs  # Time vector
    long_tones = np.sum([amplitudes[i] * np.sin(2 * np.pi * f * t) for i, f in enumerate(frequencies)], axis=0)

    return input_signal + long_tones


def _add_short_tone(input_signal):
    """Add new tones at specified times to the signal."""
    t = np.arange(length) / Fs  # Time vector
    add_tones = np.zeros_like(input_signal)

    for f, start, end, amp in zip(add_frequencies, start_time, end_time, add_amplitudes):
        mask = (np.arange(length) >= start) & (np.arange(length) < end)
        add_tones[mask] += amp * np.sin(2 * np.pi * f * t[mask])

    return input_signal + add_tones


def _add_chirp(input_signal):
    """Adds a repeating up-down chirp signal to the input signal."""

    t_chirp = np.arange(chirp_length) / Fs

    # Create one up-down chirp cycle
    chirp_signal_up = chirp_amplitude * np.sin(2 * np.pi * (chirp_min_frequency * t_chirp +
                                               (chirp_max_frequency - chirp_min_frequency) * t_chirp**2 / (2 * t_chirp[-1])))
    chirp_signal_down = chirp_amplitude * np.sin(2 * np.pi * (chirp_max_frequency * t_chirp +
                                                 (chirp_min_frequency - chirp_max_frequency) * t_chirp**2 / (2 * t_chirp[-1])))
    one_chirp_cycle = np.concatenate([chirp_signal_up, chirp_signal_down])

    # Repeat the chirp cycle to cover the entire input signal length
    num_repeats = int(np.ceil(length / len(one_chirp_cycle)))  # Calculate how many full cycles we need
    repeated_chirp = np.tile(one_chirp_cycle, num_repeats)  # Repeat the cycle
    chirp_signal = repeated_chirp[:length]  # Truncate to the input signal length

    return input_signal + chirp_signal


def _add_noise(input_signal):
    """Add white Gaussian noise to the input signal based on a given SNR."""
    signal_power = np.mean(input_signal**2)  # Compute signal power
    noise_power = signal_power / (10**(SNR_dB / 10))  # Compute noise power based on SNR
    noise = np.sqrt(noise_power) * np.random.randn(len(input_signal))  # Generate white Gaussian noise
    input_signal_with_noise = input_signal + noise  # Add noise to the signal

    return input_signal_with_noise


def _plot_input_signals(signal_0, signal_1):
    """Compute and plot the FFT of two signals in separate subplots."""
    freq_axis = np.fft.fftfreq(length, d=1/Fs)[:length//2]  # Compute positive frequencies

    # Apply Hanning window to reduce spectral leakage
    window = np.hanning(length)
    signal_0 = signal_0 * window
    signal_1 = signal_1 * window

    # Compute FFT magnitude (normalize for comparison)
    fft_0 = np.fft.fft(signal_0)
    fft_1 = np.fft.fft(signal_1)
    magnitude_0 = 20 * np.log10(np.abs(fft_0[:length//2]) + 1e-12)  # Avoid log(0)
    magnitude_1 = 20 * np.log10(np.abs(fft_1[:length//2]) + 1e-12)

    plt.figure(figsize=(10, 6))

    plt.subplot(2, 1, 1)
    plt.plot(freq_axis, magnitude_0, color="b")
    plt.ylim(bottom=0)
    plt.ylabel("Magnitude (dB)")
    plt.grid()

    plt.subplot(2, 1, 2)
    plt.plot(freq_axis, magnitude_1, color="r")
    plt.ylim(bottom=0)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude (dB)")
    plt.grid()

    plt.tight_layout()
    plt.show()
