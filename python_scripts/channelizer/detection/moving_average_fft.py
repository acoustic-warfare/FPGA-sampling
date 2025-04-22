import math
import matplotlib.pyplot as plt
import numpy as np

SCALE_FACTOR = (1 << 16)  # Scale twiddle factors to integer values
print("SCALE_FACTOR", SCALE_FACTOR, "\n")


def twos_to_int(bin_str, bits=24):
    value = int(bin_str, 2)
    if value >= (1 << (bits - 1)):
        value -= (1 << bits)
    return value


def load_samples(file_path):
    data = []
    with open(file_path, "r") as f:
        for line in f:
            data.append(twos_to_int(line.strip(), 24))
    return np.array(data, dtype=np.int32)


def generate_twiddle_factors(N):
    twiddle_lut = []
    for k in range(N // 2):
        angle = -2 * math.pi * k / N
        real = int(math.cos(angle) * SCALE_FACTOR)
        imag = int(math.sin(angle) * SCALE_FACTOR)
        twiddle_lut.append(complex(real, imag))

    return twiddle_lut


def bit_reverse_indices(N):
    num_bits = int(math.log2(N))
    return [int('{:0{width}b}'.format(i, width=num_bits)[::-1], 2) for i in range(N)]


def fft_128_point(samples, twiddle_lut):
    """Performs a 128-point FFT using fixed-point integer twiddle factors."""
    N = 128
    indices = bit_reverse_indices(N)
    ordered_samples = [complex(samples[i], 0) for i in indices]

    stage_size = 2

    while stage_size <= N:
        half_size = stage_size // 2
        twiddle_step = N // stage_size

        for i in range(0, N, stage_size):
            for j in range(half_size):
                twiddle = twiddle_lut[j * twiddle_step]
                real = twiddle.real
                imag = twiddle.imag

                a = ordered_samples[i + j]
                b = ordered_samples[i + j + half_size]

                # Fixed-point multiplication
                b_real = ((b.real * real) - (b.imag * imag)) // SCALE_FACTOR
                b_imag = ((b.real * imag) + (b.imag * real)) // SCALE_FACTOR
                b = complex(b_real, b_imag)

                ordered_samples[i + j] = a + b
                ordered_samples[i + j + half_size] = a - b

        stage_size *= 2

    return [x for x in ordered_samples]  # Normalize results


def db(x):
    return 20 * np.log10(x + 1e-10)


INPUT_FILE = './python_scripts/fft/fft_input_data.txt'
samples = load_samples(INPUT_FILE)
twiddle_lut = generate_twiddle_factors(128)

print()
# window_lut = np.hanning(128)
window_lut = np.hamming(128)
window_lut_scaled = []
for i in range(len(window_lut)):
    window_lut_scaled.append(int(window_lut[i] * SCALE_FACTOR))

num_batches = len(samples) // 128
fft_results = []
for i in range(1000):
    batch = samples[i * 128:(i + 1) * 128]
    for i in range(len(batch)):
        batch[i] = int(batch[i] * window_lut[i])
    fft_output = fft_128_point(batch, twiddle_lut)
    fft_results.append(fft_output)

fft_results = np.array(fft_results)
fft_results = fft_results[:, :64]

plt.imshow(db(np.abs(fft_results)), cmap='viridis', aspect='auto')
plt.colorbar()
plt.xlabel("Channel")
plt.ylabel("Time")
plt.show()

#
#
# moving average
#


def exponential_moving_average(input_signal, alpha):
    if not (0 < alpha <= 1) or not (0 < alpha <= 1):
        raise ValueError("Alpha must be in the range (0, 1].")
    input_signal = np.abs(input_signal) ** 2
    ema_signal = np.zeros_like(input_signal)
    ema_signal[0] = 0  # Initialize with the first value

    for i in range(1, len(input_signal)):
        ema_signal[i] = alpha * input_signal[i] + (1 - alpha) * ema_signal[i - 1]

    return ema_signal


def amplitude_lock(ema_data, allowed_subbands):
    amplitude_lock_data = np.zeros_like(ema_data)

    for col in range(ema_data.shape[1]):
        valid_indices = np.where(allowed_subbands)[0]

        if len(valid_indices) > 0:
            amplitude_max = np.max(ema_data[valid_indices, col])

            for i in valid_indices:
                if ema_data[i, col] > amplitude_max / 4:  # 5 = magic number :mage:
                    amplitude_lock_data[i, col] = 1

    return amplitude_lock_data


def plot_subplots(plt_data, allowed_subbands):
    fig, axes = plt.subplots(8, 8, figsize=(15, 20))  # 8 rows, 4 columns
    axes = axes.flatten()

    global_min = np.min(plt_data) * 0.9
    global_max = np.max(plt_data) * 1.1
    if global_min == 0:
        global_min = -0.1

    original_index = 0
    for allowed in allowed_subbands:
        ax = axes[original_index]
        subband_data = plt_data[original_index, :]  # Select the data from the second channel
        ax.plot(subband_data)
        ax.set_ylim(global_min, global_max)  # Set the y-axis limits
        if allowed == 1:
            ax.text(0.5, 0.87, f"Subband {original_index}", transform=ax.transAxes, ha='center', va='bottom')
        else:
            ax.text(0.5, 0.87, f"Subband {original_index} (Removed)", transform=ax.transAxes, ha='center', va='bottom')
        original_index += 1

    plt.tight_layout()


alpha = 1/(2**4)
ema_data = []
for i in range(0, len(fft_results[0])):
    ema = exponential_moving_average(fft_results[:, i], alpha)
    ema_data.append(ema)
ema_data = np.array(ema_data)

print(np.array(fft_results).shape)

print(np.array(ema_data).shape)
# print(ema_data)

allowed_subbands = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
plot_subplots(ema_data, allowed_subbands)
plt.show()

amplitude_lock_data = amplitude_lock(ema_data, allowed_subbands)
plot_subplots(amplitude_lock_data, allowed_subbands)
plt.show()