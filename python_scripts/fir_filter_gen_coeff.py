import numpy as np
from scipy import signal

# Filter settings
num_taps = 8  # Number of filter taps (coefficients)
passband = [300, 9000]  # Passband frequencies in Hz
fs = 48828.125  # New sampling frequency in Hz

# Generate bandpass filter coefficients using firwin
coefficients = signal.firwin(num_taps, passband, fs=fs, pass_zero=False)

# Scale coefficients to 8-bit signed integer values
Max = (2**7) - 1  # Maximum value for 8-bit signed integer
coefficients_scaled = np.round(coefficients * Max).astype(int)

# Convert coefficients to 8-bit signed values
coefficients_signed_8bit = np.clip(coefficients_scaled, -128, 127).astype(np.int8)

# Convert coefficients to hexadecimal strings for Python format
coefficients_hex_python = [
    f"{int(val) & 0xFF:02X}" for val in coefficients_signed_8bit
]

# Convert coefficients to hexadecimal strings for VHDL format
coefficients_hex_vhdl = [
    f"x\"{int(val) & 0xFF:02X}\"" for val in coefficients_signed_8bit
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
