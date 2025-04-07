import math
import matplotlib.pyplot as plt
import numpy as np

SCALE_FACTOR = (1 << 16)  # Scale twiddle factors to integer values
print("SCALE_FACTOR", SCALE_FACTOR)


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

    twiddle_lut_bin_real = [
        f"{(int(twidd.real) & 0x3FFFF):018b}" for twidd in twiddle_lut]
    twiddle_lut_bin_real_formatted = ", ".join(
        [f'"{twidd}"' for twidd in twiddle_lut_bin_real])
    print(
        f'constant twiddle_r : twiddle_type := ({twiddle_lut_bin_real_formatted});')

    twiddle_lut_bin_imag = [
        f"{(int(twidd.imag) & 0x3FFFF):018b}" for twidd in twiddle_lut]
    twiddle_lut_bin_imag_formatted = ", ".join(
        [f'"{twidd}"' for twidd in twiddle_lut_bin_imag])
    print(
        f'constant twiddle_i : twiddle_type := ({twiddle_lut_bin_imag_formatted});')

    return twiddle_lut


def bit_reverse_indices(N):
    num_bits = int(math.log2(N))
    return [int('{:0{width}b}'.format(i, width=num_bits)[::-1], 2) for i in range(N)]


def fft_128_point(samples, twiddle_lut):
    """Performs a 128-point FFT using fixed-point integer twiddle factors."""
    N = 128
    indices = bit_reverse_indices(N)
    ordered_samples = [complex(samples[i], 0) for i in indices]

    #print("--------------------------")
    #print("ordered_samples")
    #for i in range(len(ordered_samples)):
    #    print(ordered_samples[i])
    #print("--------------------------")

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

                pre_b = b

                # Fixed-point multiplication
                b_real = ((b.real * real) - (b.imag * imag)) // SCALE_FACTOR
                b_imag = ((b.real * imag) + (b.imag * real)) // SCALE_FACTOR
                b = complex(b_real, b_imag)

                #print(a)
                #print(b, j * twiddle_step)

                ordered_samples[i + j] = a + b
                ordered_samples[i + j + half_size] = a - b

                #print("! ", pre_b, "       ", b, "       index: ", i +
                #      j + half_size, "      twiddle=", real, " +i ", imag, " twiddle index", j * twiddle_step)

                #print("a + b ", a, " ", b, " ",
                #      ordered_samples[i + j], "    a_index", i + j, "b_index", i + j + half_size)
                #print("a - b ", a, " ", b, " ",
                #      ordered_samples[i + j + half_size], "    a_index", i + j, "b_index", i + j + half_size)
                #print()

            #print("-------------")
        print("===============")
        print("stage: ", stage_size)
        for i in range(len(ordered_samples)):
            print(i, " ", ordered_samples[i])
        print()

        print("===============")

        stage_size *= 2

    return [x for x in ordered_samples]  # Normalize results


def db(x):
    return 20 * np.log10(x + 1e-10)


INPUT_FILE = './python_scripts/fft/fft_input_data.txt'
samples = load_samples(INPUT_FILE)
twiddle_lut = generate_twiddle_factors(128)

num_batches = len(samples) // 128
fft_results = []

for i in range(1):
    batch = samples[i * 128:(i + 1) * 128]
    fft_output = fft_128_point(batch, twiddle_lut)
    fft_results.append(fft_output)

np_fft_result = np.fft.fft(samples[:128])

plt.figure(figsize=(10, 5))


# print(fft_results[0])


# File path (update if necessary)
file_path = "./python_scripts/fft/tb_result.txt"

# Read data from file
data = np.loadtxt(file_path, dtype=np.float64)
real = data[:128, 0]
imag = data[:128, 1]

fft_tb_result = [complex(real[i], imag[i])
                 for i in range(min(len(real), len(imag)))]


plt.plot(db(np.abs(fft_tb_result)),  marker='o')
plt.plot(db(np.abs(fft_results[0])),  marker='o')
plt.plot(db(np.abs(np_fft_result)), marker='o')


plt.xlabel('Frequency Bin')
plt.ylabel('Magnitude (dB)')
plt.title('FFT Magnitude Response Comparison')
plt.grid()
plt.show()
