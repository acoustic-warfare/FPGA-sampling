import numpy as np
import matplotlib.pyplot as plt
import glob
import os


def remove_XXXXX_top(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()

    # Find the index of the first line that is not all 'X'
    start_index = 0
    for i, line in enumerate(lines):
        if not line.strip().startswith('X') or set(line.strip()) != {'X'}:
            start_index = i
            break

    # Write back the filtered lines
    with open(filename, 'w') as file:
        file.writelines(lines[start_index:])


def read_24bit_signed(filename):
    data = []
    with open(filename, 'r') as file:
        for line in file:
            value = int(line.strip(), 2)  # Convert binary string to integer
            if value & (1 << 23):  # Check if the number is negative
                value -= (1 << 24)  # Convert to signed 24-bit integer
            data.append(value)
    return np.array(data)


# Locate files
data_file = "./data.mem"
output_files = sorted(glob.glob("./output_*.mem"))  # Get all output_n.mem files and sort them

# Ensure there's at least one output file
if not output_files:
    raise FileNotFoundError("No output_*.mem files found in the directory.")

# Remove leading XXXXXX lines from all files
for file in output_files:
    remove_XXXXX_top(file)

# Read input data and output data
data_in = read_24bit_signed(data_file)
data_outputs = [read_24bit_signed(file) for file in output_files]

# Downsample remove every nth sample
# nr_subbands = len(data_outputs)
# data_outputs = [data[::6] for data in data_outputs]
# data_outputs = [np.repeat(data, 6) for data in data_outputs]

# Compute FFT
fft_data_in = np.fft.rfft(data_in)
freqs_in = np.fft.rfftfreq(len(data_in))
fft_data_outputs = [np.fft.rfft(data) for data in data_outputs]
freqs_outputs = [np.fft.rfftfreq(len(data)) for data in data_outputs]

# Convert to decibels
fft_data_in = 20 * np.log10(np.abs(fft_data_in))
fft_data_outputs = [20 * np.log10(np.abs(fft)) for fft in fft_data_outputs]

# Plot FFT results
plt.figure(figsize=(12, 6))
plt.subplot(2, 1, 1)
plt.plot(freqs_in * 48828.125, np.abs(fft_data_in))
plt.ylabel("Magnitude")
plt.grid()

plt.subplot(2, 1,  2)
plt.xlabel("Frequency")
plt.ylabel("Magnitude (Output)")
plt.grid()
for i, (fft_data, freqs) in enumerate(zip(fft_data_outputs, freqs_outputs)):
    plt.plot(freqs * 48828.125, np.abs(fft_data))

plt.show()
