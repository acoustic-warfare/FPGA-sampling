import math
import matplotlib.pyplot as plt
import numpy as np

SCALE_FACTOR = (1 << 15)  # Scale twiddle factors to integer values


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

    twiddle_lut_hex_real = [f"{(int(twidd.real) & 0xFFFFF):05X}" for twidd in twiddle_lut]
    twiddle_lut_hex_real_formatted = ", ".join([f'x"{twidd}"' for twidd in twiddle_lut_hex_real])
    print(f"constant twidle_r : twidle_type := ({twiddle_lut_hex_real_formatted});")

    twiddle_lut_hex_imag = [f"{(int(twidd.imag) & 0xFFFFF):05X}" for twidd in twiddle_lut]
    twiddle_lut_hex_imag_formatted = ", ".join([f'x"{twidd}"' for twidd in twiddle_lut_hex_imag])
    print(f"constant twidle_i : twidle_type := ({twiddle_lut_hex_imag_formatted});")

    return twiddle_lut


def bit_reverse_indices(N):
    num_bits = int(math.log2(N))
    return [int('{:0{width}b}'.format(i, width=num_bits)[::-1], 2) for i in range(N)]


def fft_32_point(samples, twiddle_lut):
    """Performs a 32-point FFT using fixed-point integer twiddle factors."""
    N = 32
    indices = bit_reverse_indices(N)
    ordered_samples = [complex(samples[i], 0) for i in indices]  # Ensure complex format

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

                print("a + b ", a, " ", b, " ", ordered_samples[i + j], "    a_index", i + j, "b_index", i + j + half_size)
                print("a - b ", a, " ", b, " ", ordered_samples[i + j + half_size], "    a_index", i + j, "b_index", i + j + half_size)
                print()

            print("-------------")

        print("===============")

        stage_size *= 2

    return [x / N for x in ordered_samples]  # Normalize results


def plot_magnitude_response(fft_results):
    magnitude_db = 20 * np.log10(fft_results + 1e-10)
    plt.plot(magnitude_db, linestyle='-', marker='o')
    plt.xlabel('Frequency Bin')
    plt.ylabel('Magnitude (dB)')
    plt.title('FFT Magnitude Response Comparison')
    plt.grid()


if __name__ == "__main__":
    INPUT_FILE = './python_scripts/fft/fft_input_data.txt'
    samples = load_samples(INPUT_FILE)
    twiddle_lut = generate_twiddle_factors(32)

    num_batches = len(samples) // 32
    fft_results = []

    for i in range(1):
        batch = samples[i * 32:(i + 1) * 32]
        fft_output = fft_32_point(batch, twiddle_lut)
        fft_results.append(fft_output)

    np_fft_result = np.fft.fft(samples[:32]) / 32

    avg_magnitude = np.zeros(32)
    for batch in fft_results:
        avg_magnitude += np.abs(batch)

    plt.figure(figsize=(10, 5))
    plot_magnitude_response(np.abs(avg_magnitude))
    plot_magnitude_response(np.abs(np_fft_result))
    plt.show()

    print(fft_results[0])
