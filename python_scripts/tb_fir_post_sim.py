import numpy as np
import matplotlib.pyplot as plt

# Settings
Text_file_input = "filter_coefficients/filter_input.txt"
Text_file_output = "filter_coefficients/filter_output.txt"

# Function to read samples from a file
def read_samples(file_path):
    with open(file_path, "r") as file:
        samples = [int(line.strip()) for line in file]
    return np.array(samples)

# Function to smooth data using a moving average
def moving_average(data, window_size):
    return np.convolve(data, np.ones(window_size)/window_size, mode='same')

# Read samples from the input and output files
input_samples = read_samples(Text_file_input)
output_samples = read_samples(Text_file_output)

# Determine the length of the signals
input_length = len(input_samples)
output_length = len(output_samples)
min_length = min(input_length, output_length)

# Trim the longer signal to match the length of the shorter signal
if input_length > min_length:
    input_samples = input_samples[:min_length]
elif output_length > min_length:
    output_samples = output_samples[:min_length]

# Compute FFT of input and output samples
input_fft = np.fft.fft(input_samples)
output_fft = np.fft.fft(output_samples)

# Frequency axis
sample_rate = 48828.125  # Example sample rate in Hz, adjust as necessary
frequencies = np.fft.fftfreq(min_length, 1 / sample_rate)

# Select frequencies within 0-10000 Hz
max_freq = 20000
indices = np.where((frequencies >= 0) & (frequencies <= max_freq))
selected_frequencies = frequencies[indices]

# Smooth FFT of input and output signals
window_size = 50  # Adjust this value to control the amount of smoothing
smoothed_input_fft = moving_average(np.abs(input_fft), window_size)
smoothed_output_fft = moving_average(np.abs(output_fft), window_size)

# Calculate magnitude response
magnitude_response = smoothed_output_fft[indices] / smoothed_input_fft[indices]

# Plot the samples and magnitude response
plt.figure(figsize=(14, 18))

# Plot Input Signal
plt.subplot(5, 1, 1)
plt.plot(input_samples, label="Input Samples")
plt.title("Input Samples")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.legend()

# Plot Output Signal
plt.subplot(5, 1, 2)
plt.plot(output_samples, label="Output Samples", color="orange")
plt.title("Output Samples")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.legend()

# Plot FFT of Input Signal
plt.subplot(5, 1, 3)
plt.plot(selected_frequencies, smoothed_input_fft[indices], label="Smoothed FFT of Input Samples")
plt.title("Smoothed FFT of Input Samples (0-10000 Hz)")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude")
plt.legend()

# Plot FFT of Output Signal
plt.subplot(5, 1, 4)
plt.plot(selected_frequencies, smoothed_output_fft[indices], label="Smoothed FFT of Output Samples", color="orange")
plt.title("Smoothed FFT of Output Samples (0-10000 Hz)")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude")
plt.legend()

# Plot Magnitude Response for 0-10000 Hz
plt.subplot(5, 1, 5)
plt.plot(selected_frequencies, magnitude_response)
plt.title("Magnitude Response (0-10000 Hz)")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude")
plt.grid(True)

plt.tight_layout()
plt.show()
