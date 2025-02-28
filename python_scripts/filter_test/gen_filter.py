import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt

Fs = 48828.125  # Sampling Rate

num_taps = 55  # Number of taps per filter
M = 32

filter_width = Fs / (2 * M)
center_frequencies = np.linspace(filter_width/2, Fs/2 - filter_width/2, M, endpoint=True)  # Subband centers

print("num_taps", num_taps)
print("num_subbands", M)


# Floating-point filter design
filters = []
for center_frecuency in center_frequencies:
    low_edge = max(0.1, center_frecuency - filter_width/2)
    high_edge = min(Fs / 2 - 0.1, center_frecuency + filter_width/2)
    # print("low_edge:", low_edge, "  high_edge:", high_edge)
    taps = signal.firwin(num_taps, [low_edge, high_edge], fs=Fs, pass_zero=False)
    filters.append(taps)

plt.figure(figsize=(8, 6))

# Plot floating-point response
plt.subplot(2, 1, 1)
for i in range(0, len(filters)):  # Plot a subset of filters
    w, h = signal.freqz(filters[i], worN=1024, fs=Fs)
    plt.plot(w, 20 * np.log10(abs(h) + 1e-12), label=f"Filter {i} ({center_frequencies[i]:.1f} Hz)")
ylim1 = plt.gca().get_ylim()
plt.legend()

# Scale coefficients to fixed-point
filters_scaled_all = []
for filter in filters:
    max_scale = 2**11 / np.max(np.abs(filter))  # Scale to fit 12-bit range
    scale_factor = 2**int(np.floor(np.log2(max_scale)))  # Ensure power-of-2 scaling
    print("scale_factor=2**", int(np.floor(np.log2(max_scale))))

    filter_scaled = np.round(filter * scale_factor).astype(np.int16)  # Keep int16 to avoid overflow
    filter_scaled = np.clip(filter_scaled, -2048, 2047)  # Ensure values fit in 12-bit range
    filters_scaled_all.append(filter_scaled)

    # filter fixed point for plot
    filter_fixed_point = filter_scaled / scale_factor

    plt.subplot(2, 1, 2)
    w, h = signal.freqz(filter_fixed_point, worN=1024, fs=Fs)
    plt.plot(w, 20 * np.log10(abs(h) + 1e-12))
    plt.ylabel("Magnitude (dB)")
    plt.xlabel("Frequency (Hz)")
    plt.ylim(ylim1)

plt.show()


def print_all_vhdl_format(filters):
    num_filters = len(filters)
    for i, filter in enumerate(filters):
        taps_hex = [f"{(tap & 0xFFF):03X}" for tap in filter]  # Convert to 12-bit hex
        formatted = ", ".join([f'x"{tap}"' for tap in taps_hex])
        if i < num_filters - 1:
            print(f"({formatted}),")
        else:
            print(f"({formatted})")   # No comma for last row


#filters_scaled_all = np.array(filters_scaled_all)[::-1]  # Reverse the rows
print_all_vhdl_format(np.array(filters_scaled_all))
