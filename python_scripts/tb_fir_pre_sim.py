import numpy as np
import matplotlib.pyplot as plt

# Settings
Data_Width = 24  # Filter data width
Offset = 1  # Pipeline/Buffering registers
N = 1000  # Test input length
Text_file_input = 'filter_coefficients/filter_input.txt'
Shift = 5  # Constant Data shift
fs = 48828.125  # Sampling frequency in Hz
sine_freq1 = 100  # Sine wave frequency 1 in Hz
sine_freq2 = 1000  # Sine wave frequency 2 in Hz

# Generate the sine waves
t = np.arange(N) / fs
sine_wave1 = np.sin(2 * np.pi * sine_freq1 * t)
sine_wave2 = np.sin(2 * np.pi * sine_freq2 * t)

# Sum the two sine waves
sine_wave = sine_wave1 + sine_wave2

# Scale and convert the sine wave to integers with a specific data width
max_val = 2**(Data_Width - 1) - 1
min_val = -2**(Data_Width - 1)
sine_wave_scaled = np.int32(sine_wave * max_val / 2)  # Divide by 2 to prevent overflow

# Shift the data
sine_wave_shifted = sine_wave_scaled >> Shift

# Save the samples to a text file
with open(Text_file_input, 'w') as file:
    for sample in sine_wave_shifted:
        file.write(f"{sample}\n")

print(f"Sine wave samples saved to {Text_file_input}")

# Plot the generated sine wave
#plt.figure(figsize=(14, 6))
#plt.plot(t, sine_wave, label='Summed Sine Wave (200 Hz + 1000 Hz)')
#plt.title('Summed Sine Wave')
#plt.xlabel('Time [s]')
#plt.ylabel('Amplitude')
#plt.legend()
#plt.show()
#