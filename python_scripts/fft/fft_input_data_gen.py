import numpy as np

# Parameters
length = 3200  # Number of points
Fs = 48828.125  # Sampling frequency in Hz
f_sine = 4000
OUTPUT_FILE = './python_scripts/fft/fft_input_data.txt'

# Generate sine wave
t = np.arange(length) / Fs
sine_wave = np.sin(2 * np.pi * f_sine * t)
data = (sine_wave * (2**16 - 1)).astype(np.int32)  # Scale to 18-bit integer range (more like array data)


def int_to_twos(num, bits):
    mask = (1 << bits) - 1
    return "{:0{}b}".format(num & mask, bits)


f = open(OUTPUT_FILE, "w")
for i in range(0, length):
    f.write(int_to_twos(round(data[i]), 24))
    f.write("\n")

f.close

print(f"Generated {length} points of 24-bit integer sine wave data and saved to {OUTPUT_FILE}")
