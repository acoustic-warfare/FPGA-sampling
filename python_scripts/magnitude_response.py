import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

# Define filter parameters
num_taps = 127  # Number of coefficients
cutoff = 200  # Cutoff frequency in Hz
fs = 48828.125  # Sampling frequency in Hz
nr_bits = 8

# Step 1: Design the FIR high-pass filter and get the coefficients
coefficients = signal.firwin(num_taps, cutoff, fs=fs, pass_zero=False)
print("1", coefficients)

# Step 2: Scale coefficients to 8-bit signed integer values
Max = (2 ** (nr_bits - 1)) - 1  # Maximum value for 8-bit signed integer
coefficients = coefficients * Max
print("2", coefficients)

coefficients_scaled = np.round(coefficients).astype(int)
print("3", coefficients_scaled)

# Convert coefficients to 8-bit signed values
# coefficients_signed_8bit = np.clip(coefficients_scaled, -128, 127).astype(np.int8)
# print("3", coefficients_signed_8bit)

# Compute the frequency response
w, h = signal.freqz(coefficients_scaled, fs=fs)

plt.figure()
plt.plot(w, 20 * np.log10(np.abs(h)), "b")
plt.title("Magnitude Response")
plt.xlabel("Frequency [Hz]")
plt.ylabel("Amplitude [dB]")
plt.grid()
plt.show()


def print_coefficients(coefficients_scaled, nr_bits):
    max_val = (1 << nr_bits) - 1  # Calculate the maximum value based on nr_bits
    hex_format = f"{{:0{(nr_bits + 3) // 4}X}}"  # Create format string based on nr_bits
    hex_vhdl_format = f'x"{{:0{(nr_bits + 3) // 4}X}}"'

    coefficients_hex_python = [
        hex_format.format(int(val) & max_val) for val in coefficients_scaled
    ]
    coefficients_hex_vhdl = [
        hex_vhdl_format.format(int(val) & max_val) for val in coefficients_scaled
    ]

    print("coefficients_hex_python:")
    print(coefficients_hex_python)

    print("\ncoefficients_hex_vhdl:")
    for idx, hex_val in enumerate(coefficients_hex_vhdl):
        if idx % 16 == 0:
            print("")
        print(f"\t{hex_val},", end="")
    print("\n);")  # To close the VHDL array declaration


print_coefficients(coefficients_scaled, nr_bits)
