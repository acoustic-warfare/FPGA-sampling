import numpy as np
import matplotlib.pyplot as plt


def read_24bit_signed(filename):
    data = []
    with open(filename, 'r') as file:
        for line in file:
            value = int(line.strip(), 2)  # Convert binary string to integer
            if value & (1 << 23):  # Check if the number is negative
                value -= (1 << 24)  # Convert to signed 24-bit integer
            data.append(value)
    return np.array(data)


# Load data
file1 = "./data.mem"
file2 = "./output.mem"
data1 = read_24bit_signed(file1)
data2 = read_24bit_signed(file2)

# Compute FFT
fft_data1 = np.fft.rfft(data1)
fft_data2 = np.fft.rfft(data2)

freqs1 = np.fft.rfftfreq(len(data1))
freqs2 = np.fft.rfftfreq(len(data2))

fft_data1 = 20 * np.log10(np.abs(fft_data1))
fft_data2 = 20 * np.log10(np.abs(fft_data2))

# Plot FFT results
plt.figure(figsize=(12, 6))
plt.subplot(2, 1, 1)
plt.plot(freqs1 * 48828.125, np.abs(fft_data1))
plt.ylabel("Magnitude")
plt.grid()

plt.subplot(2, 1, 2)
plt.plot(freqs2 * 48828.125, np.abs(fft_data2))
plt.xlabel("Frequency")
plt.ylabel("Magnitude")
plt.grid()

plt.tight_layout()
plt.show()
