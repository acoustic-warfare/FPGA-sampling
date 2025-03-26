import numpy as np
import matplotlib.pyplot as plt

######################
# START USER PARAMETERS

# General
Fs = 48828.125  # Sampling Rate

max_length = 50000  # Number of samples
max_amplitude = 1000000  # Max amplitude (all signals are normilized to this value at the end)

# Input signal
frequencies = [1300, 10000, 20000]
amplitudes = [100, 100, 100]

# Add tone after set time
add_frequencies = [5000, 15000]
add_amplitudes = [100, 20]
start_time = [20000, 50000]
end_time = [40000, 100000]

# Add chirp
chirp_min_frequency = 2000
chirp_max_frequency = 12000
chirp_amplitude = 50
chirp_length = 25000

# Noise parameters
SNR_dB = 20  # Desired Signal-to-Noise Ratio in dB


file_name_sim = "./data.mem"
file_name_build = "./pl/src/simulated_array/data.mem"

# END USER PARAMETERS
####################
print(max_length)


def generate_signal(long_tone=True, shot_tone=True, chirp=True, counter=False, noise=True, normalize=True, plt=True):
    input_signal = np.zeros(max_length)
    sig_no_noise = np.zeros(max_length)

    if long_tone:
        input_signal = add_long_tone(input_signal)
        sig_no_noise = add_long_tone(sig_no_noise)
    if shot_tone:
        input_signal = add_short_tone(input_signal)
        sig_no_noise = add_short_tone(sig_no_noise)
    if chirp:
        input_signal = add_chirp(input_signal)
        sig_no_noise = add_chirp(sig_no_noise)
    if counter:
        input_signal = add_counter(input_signal)
        sig_no_noise = add_counter(sig_no_noise)
    if noise:
        input_signal = add_noise(input_signal)

    if normalize:
        input_signal = add_normalize(input_signal, max_amplitude)
        sig_no_noise = add_normalize(sig_no_noise, max_amplitude)

    if plt:
        plot_input_signals(sig_no_noise, input_signal)

    return input_signal


def add_long_tone(input_signal):
    t = np.arange(max_length) / Fs  # Time vector
    long_tones = np.sum([amplitudes[i] * np.sin(2 * np.pi * f * t) for i, f in enumerate(frequencies)], axis=0)

    return input_signal + long_tones


def add_short_tone(input_signal):
    """Add new tones at specified times to the signal."""
    t = np.arange(max_length) / Fs  # Time vector
    add_tones = np.zeros_like(input_signal)

    for f, start, end, amp in zip(add_frequencies, start_time, end_time, add_amplitudes):
        mask = (np.arange(max_length) >= start) & (np.arange(max_length) < end)
        add_tones[mask] += amp * np.sin(2 * np.pi * f * t[mask])

    return input_signal + add_tones


def add_chirp(input_signal):
    """Adds a repeating up-down chirp signal to the input signal."""

    t_chirp = np.arange(chirp_length) / Fs

    # Create one up-down chirp cycle
    chirp_signal_up = chirp_amplitude * np.sin(2 * np.pi * (chirp_min_frequency * t_chirp +
                                               (chirp_max_frequency - chirp_min_frequency) * t_chirp**2 / (2 * t_chirp[-1])))
    chirp_signal_down = chirp_amplitude * np.sin(2 * np.pi * (chirp_max_frequency * t_chirp +
                                                 (chirp_min_frequency - chirp_max_frequency) * t_chirp**2 / (2 * t_chirp[-1])))
    one_chirp_cycle = np.concatenate([chirp_signal_up, chirp_signal_down])

    # Repeat the chirp cycle to cover the entire input signal length
    num_repeats = int(np.ceil(max_length / len(one_chirp_cycle)))  # Calculate how many full cycles we need
    repeated_chirp = np.tile(one_chirp_cycle, num_repeats)  # Repeat the cycle
    chirp_signal = repeated_chirp[:max_length]  # Truncate to the input signal length

    return input_signal + chirp_signal


def add_counter(input_signal):
    counter = np.arange(max_length)
    return input_signal + counter


def add_noise(input_signal):
    """Add white Gaussian noise to the input signal based on a given SNR."""
    signal_power = np.mean(input_signal**2)  # Compute signal power
    noise_power = signal_power / (10**(SNR_dB / 10))  # Compute noise power based on SNR
    noise = np.sqrt(noise_power) * np.random.randn(len(input_signal))  # Generate white Gaussian noise
    input_signal_with_noise = input_signal + noise  # Add noise to the signal

    return input_signal_with_noise


def add_normalize(input_signal, max_amplitude):
    current_max = np.max(np.abs(input_signal))
    if current_max == 0:
        return input_signal

    normalized_signal = (input_signal / current_max) * max_amplitude
    return normalized_signal


def plot_input_signals(signal_0, signal_1):
    """Compute and plot the FFT of two signals in separate subplots."""
    freq_axis = np.fft.fftfreq(max_length, d=1/Fs)[:max_length//2]  # Compute positive frequencies

    # Apply Hanning window to reduce spectral leakage
    window = np.hanning(max_length)
    signal_0 = signal_0 * window
    signal_1 = signal_1 * window

    # Compute FFT magnitude (normalize for comparison)
    fft_0 = np.fft.fft(signal_0)
    fft_1 = np.fft.fft(signal_1)
    magnitude_0 = 20 * np.log10(np.abs(fft_0[:max_length//2]) + 1e-12)  # Avoid log(0)
    magnitude_1 = 20 * np.log10(np.abs(fft_1[:max_length//2]) + 1e-12)

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


def int_to_twos(num, bits):
    mask = (1 << bits) - 1
    return "{:0{}b}".format(num & mask, bits)


def save_sample_data_to_file(file_name, length, samples):
    f = open(file_name, "w")
    # f.write(int_to_twos(length, 24))
    # f.write("\n")
    for i in range(0, length):
        f.write(int_to_twos(round(samples[i]), 24))
        f.write("\n")

    f.close


# input_signal = generate_signal(long_tone=True, shot_tone=True, chirp=True, counter=False, noise=True, normalize=True, plt=True)
# input_signal = generate_signal(long_tone=False, shot_tone=False, chirp=False, counter=True, noise=False, normalize=False, plt=True)
input_signal = generate_signal(long_tone=False, shot_tone=False, chirp=True, counter=False, noise=False, normalize=False, plt=True)


save_sample_data_to_file(file_name_build, max_length, input_signal)
save_sample_data_to_file(file_name_sim, max_length, input_signal)
