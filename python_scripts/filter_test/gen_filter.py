import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt

Fs = 48828.125  # Sampling Rate
num_taps = 32  # Number of taps per filter
high_edge = 500  # Cutoff frequency

# Floating-point filter design
taps = signal.firwin(num_taps, cutoff=high_edge, fs=Fs, pass_zero=True)

plt.figure(figsize=(8, 6))

# Plot floating-point response
plt.subplot(2, 1, 1)
w, h = signal.freqz(taps, worN=1024, fs=Fs)
plt.plot(w, 20 * np.log10(abs(h) + 1e-12), label="Floating-Point Filter")
plt.ylabel("Magnitude (dB)")
plt.title("Filter Frequency Response")
plt.legend()
ylim1 = plt.gca().get_ylim()

# Scale coefficients to fixed-point
scale_factor = 2**12  # Scaling factor for fixed-point
taps_scaled = np.round(taps * scale_factor).astype(np.int16)

# Convert back to floating-point for correct freqz() evaluation
taps_fixed_point = taps_scaled / scale_factor

# Plot fixed-point response
plt.subplot(2, 1, 2)
w, h = signal.freqz(taps_fixed_point, worN=1024, fs=Fs)
plt.plot(w, 20 * np.log10(abs(h) + 1e-12), label="Fixed-Point Filter")
plt.ylabel("Magnitude (dB)")
plt.xlabel("Frequency (Hz)")
plt.ylim(ylim1)
plt.legend()

plt.show()

# Convert to 16-bit hex values
taps_hex = [f"{np.uint16(tap):04X}" for tap in taps_scaled]
taps_hex = np.array(taps_hex)


def print_vhdl_format(taps_hex):
    formatted = ", ".join([f'x"{tap}"' for tap in taps_hex])
    print(formatted)


print_vhdl_format(taps_hex)
