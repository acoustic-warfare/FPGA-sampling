import numpy as np
import matplotlib.pyplot as plt

# Settings
Text_file_input =  'filter_coefficients/filter_input.txt'
Text_file_output = 'filter_coefficients/filter_output.txt'

# Function to read samples from a file
def read_samples(file_path):
    with open(file_path, 'r') as file:
        samples = [int(line.strip()) for line in file]
    return np.array(samples)

# Read samples from the input and output files
input_samples = read_samples(Text_file_input)
output_samples = read_samples(Text_file_output)

# Plot the samples
plt.figure(figsize=(14, 6))

plt.subplot(2, 1, 1)
plt.plot(input_samples, label='Input Samples')
plt.title('Input Samples')
plt.xlabel('Sample Index')
plt.ylabel('Amplitude')
plt.legend()

plt.subplot(2, 1, 2)
plt.plot(output_samples, label='Output Samples', color='orange')
plt.title('Output Samples')
plt.xlabel('Sample Index')
plt.ylabel('Amplitude')
plt.legend()

plt.tight_layout()
plt.show()