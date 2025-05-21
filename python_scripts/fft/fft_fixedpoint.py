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

    # print("--------------------------")
    # print("samples")
    # for i in range(len(samples)):
    #    print(samples[i])
    # print("--------------------------")

    # print("--------------------------")
    # print("ordered_samples")
    # for i in range(len(ordered_samples)):
    #    print(ordered_samples[i])
    # print("--------------------------")

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

                # print(a)
                # print(b, j * twiddle_step)

                ordered_samples[i + j] = a + b
                ordered_samples[i + j + half_size] = a - b

                # print("! ", pre_b, "       ", b, "       index: ", i +
                #      j + half_size, "      twiddle=", real, " +i ", imag, " twiddle index", j * twiddle_step)

                # print("a + b ", a, " ", b, " ",
                #      ordered_samples[i + j], "    a_index", i + j, "b_index", i + j + half_size)
                # print("a - b ", a, " ", b, " ",
                #      ordered_samples[i + j + half_size], "    a_index", i + j, "b_index", i + j + half_size)
                # print()

            # print("-------------")
        # print("===============")
        # print("stage: ", stage_size)
        # for i in range(len(ordered_samples)):
        #    print(i, " ", ordered_samples[i])
        # print()
        # print("===============")

        stage_size *= 2

    return [x for x in ordered_samples]  # Normalize results


def db(x):
    return 20 * np.log10(x + 1e-10)


INPUT_FILE = './python_scripts/fft/fft_input_data.txt'
samples = load_samples(INPUT_FILE)
twiddle_lut = generate_twiddle_factors(128)

print()
# window_lut = np.blackman(128)
# window_lut = np.hanning(128)
window_lut = np.hamming(128)
# window_lut = np.ones(128) #rectangular

window_lut_scaled = []
for i in range(len(window_lut)):
    window_lut_scaled.append(int(window_lut[i] * SCALE_FACTOR))

window_lut_scaled_hex = [f"{(int(num) & 0x3FFFF):018b}" for num in window_lut_scaled[:64]]
window_lut_scaled_hex_formatted = ", ".join([f'"{num}"' for num in window_lut_scaled_hex])
print(
    f'constant window : window_type := ({window_lut_scaled_hex_formatted});')


num_batches = len(samples) // 128
fft_results = []
for i in range(1):
    batch = samples[i * 128:(i + 1) * 128]
    for i in range(len(batch)):
        batch[i] = int(batch[i] * window_lut[i])
    fft_output = fft_128_point(batch, twiddle_lut)
    fft_results.append(fft_output)


np_fft_result = np.fft.fft(samples[:128] * window_lut)

plt.figure(figsize=(10, 5))


# print(fft_results[0])


# File path (update if necessary)
file_path = "./python_scripts/fft/tb_result.txt"

# Read data from file
data = np.loadtxt(file_path, dtype=np.float64)
real = data[256:384, 0]
imag = data[256:384, 1]

# real = data[512:640, 0]
# imag = data[512:640, 1]

fft_tb_result = [complex(real[i], imag[i])
                 for i in range(min(len(real), len(imag)))]

fft_tb_result_all = []
for i in range(int(len(data[:, 0])/128)):
    full_sample = [complex(data[i * 128 + j, 0], data[i * 128 + j, 1]) for j in range(128)]
    fft_tb_result_all.append(full_sample)

plt.plot(db(np.abs(fft_tb_result)),  marker='o', label="tb_res")
plt.plot(db(np.abs(fft_results[0])),  marker='o', label="fixed_point")
plt.plot(db(np.abs(np_fft_result)), marker='o', label="numpy")

plt.xlabel('Frequency Bin')
plt.ylabel('Magnitude (dB)')
plt.title('FFT Magnitude Response Comparison')
plt.legend()
plt.grid()
plt.show()

plt.imshow(db(np.abs(fft_tb_result_all)), cmap='viridis', aspect='auto')
plt.colorbar()
plt.xlabel("Channel")
plt.ylabel("Time")
plt.show()


plt.figure(2)
plt.plot(np.ones(128), label="ones")
plt.plot(np.hanning(128), label="hanning")
plt.plot(np.hamming(128), label="hamming")
plt.plot(np.blackman(128), label="blackman")
plt.legend()
plt.show()
