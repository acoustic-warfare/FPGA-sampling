import math
import matplotlib.pyplot as plt
import numpy as np


def twos_to_int(bin_str, bits=24):
    value = int(bin_str, 2)
    if value >= (1 << (bits - 1)):
        value -= (1 << bits)
    return value


def load_samples(file_path):
    # Read data from file
    data = []
    with open(INPUT_FILE, "r") as f:
        for line in f:
            data.append(twos_to_int(line.strip(), 24))

    data = np.array(data, dtype=np.int32)
    return data


def generate_twiddle_factors(N):
    """Generates a lookup table for twiddle factors."""
    twiddle_lut = []
    for k in range(N // 2):
        angle = -2 * math.pi * k / N
        twiddle_lut.append(complex(math.cos(angle), math.sin(angle)))
    print()
    formatted_list = [f"{c.real:.2f} + {c.imag:.2f}j" for c in twiddle_lut]
    print(f"{formatted_list}")
    print()
    return twiddle_lut


def bit_reverse_indices(N):
    """Computes the bit-reversed indices for an N-point FFT."""
    num_bits = int(math.log2(N))
    indices = [int('{:0{width}b}'.format(i, width=num_bits)[::-1], 2) for i in range(N)]
    return indices


def fft_32_point(samples, twiddle_lut):
    """Performs a 32-point FFT using a LUT for twiddle factors."""
    N = 32
    indices = bit_reverse_indices(N)
    ordered_samples = [samples[i] for i in indices]

    print()
    print(ordered_samples)
    print()

    # Iterative FFT
    stage_size = 2
    while stage_size <= N:
        half_size = stage_size // 2
        twiddle_step = N // stage_size

        for i in range(0, N, stage_size):
            for j in range(half_size):
                print("i ", i, "   j ", j, "   twiddle_idex ", j * twiddle_step, f"   twiddle: {twiddle_lut[j * twiddle_step]:.2f} ")
                twiddle = twiddle_lut[j * twiddle_step]
                print(twiddle)

                a = ordered_samples[i + j]
                b = ordered_samples[i + j + half_size] * twiddle

                ordered_samples[i + j] = a + b
                ordered_samples[i + j + half_size] = a - b

                print(ordered_samples)

                print()
            print("-----------------------------------------------------------------------")
            print()

        stage_size *= 2

        print("=======================================================================")
        print()

    # Normalize by N to match FFT scaling
    return [x / N for x in ordered_samples]


def plot_magnitude_response(fft_results):
    """Plots the averaged magnitude response of all FFT output batches alongside np.fft."""

    # Convert to log scale for better visualization
    magnitude_db = 20 * np.log10(fft_results + 1e-10)  # Avoid log(0)

    # Plot the magnitude spectrum
    plt.plot(magnitude_db, linestyle='-', marker='o')
    plt.xlabel('Frequency Bin')
    plt.ylabel('Magnitude (dB)')
    plt.title('FFT Magnitude Response Comparison')
    plt.grid()


if __name__ == "__main__":
    INPUT_FILE = './python_scripts/fft/fft_input_data.txt'
    samples = load_samples(INPUT_FILE)

    twiddle_lut = generate_twiddle_factors(32)

    # Process in batches of 32
    num_batches = len(samples) // 32
    fft_results = []

    for i in range(1):
        batch = samples[i * 32:(i + 1) * 32]
        fft_output = fft_32_point(batch, twiddle_lut)
        fft_results.append(fft_output)

    # Compute NumPy FFT for comparison
    np_fft_result = np.fft.fft(samples[:32]) / 32  # Normalize for comparison

    # Print first batch result as an example
    # print("First FFT output batch:")
    # for val in fft_results[0]:
    #    print(val)

    print()
    print(np.abs(fft_results))
    print(np.abs(np_fft_result))
    print()

    avg_magnitude = np.zeros(32)
    for batch in fft_results:
        avg_magnitude += np.abs(batch)

    # Plot magnitude response of averaged FFT result with NumPy FFT
    plt.figure(figsize=(10, 5))
    plot_magnitude_response(np.abs(avg_magnitude))
    plot_magnitude_response(np.abs(np_fft_result))
    plt.show()


# ['1.00 + -0.00j', '0.98 + -0.20j', '0.92 + -0.38j', '0.83 + -0.56j', '0.71 + -0.71j', '0.56 + -0.83j', '0.38 + -0.92j', '0.20 + -0.98j', '0.00 + -1.00j', '-0.20 + -0.98j', '-0.38 + -0.92j', '-0.56 + -0.83j', '-0.71 + -0.71j', '-0.83 + -0.56j', '-0.92 + -0.38j', '-0.98 + -0.20j']
