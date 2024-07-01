import numpy as np
from scipy import signal

# Filter settings
num_taps = 32  # Number of filter taps (coefficients)
passband = [300, 9000]  # Passband frequencies in Hz
fs = 48828.125  # New sampling frequency in Hz

# Generate bandpass filter coefficients using firwin
coefficients = signal.firwin(num_taps, passband, fs=fs, pass_zero=False)

# Scale coefficients to integer values
Max = (2**15) - 1  # Assuming 16-bit coefficients
coefficients_scaled = np.round(coefficients * Max).astype(int)

# Convert coefficients to hexadecimal strings for Python format
coefficients_hex_python = [
    f"{val & 0xFFFF:04X}" for val in coefficients_scaled
]

# Convert coefficients to hexadecimal strings for VHDL format
coefficients_hex_vhdl = [
    f"x\"{val & 0xFFFF:04X}\"" for val in coefficients_scaled
]

# Print or use the coefficients in hexadecimal format
print("coefficients_hex_python:")
print(coefficients_hex_python)

print("\ncoefficients_hex_vhdl:")
for idx, hex_val in enumerate(coefficients_hex_vhdl):
    if idx % 8 == 0:
        print("")
    print(f"\t{hex_val},", end="")

print("\n);")  # To close the VHDL array declaration
