import numpy as np
import matplotlib.pyplot as plt

sampling_rate = 48828.125  # (FPGA sampling rate) [Hz]

######################
# START USER PARAMETERS
# Desired frequency [Hz]
frequency = 400

# Max multiple [nr] (number of periods max to get closer to desired frequency)
max_multiple = 10

# Max amplitude of output
# 24 bit signed means max is ...?
max_amplitude = 1000

file_name = "test_file.mem"
# END USER PARAMETERS
####################
print("Desired frequency: ", frequency, "   max_multiple", max_multiple)

# try all multiples and see which is best
# in reality you only need to test prime multiples, rest are useless
lowes_delta = 999999
best_multiple = 1
for i in range(1, max_multiple + 1):
    lenght = round(sampling_rate*i/frequency)
    actual_frequency = sampling_rate * i / lenght
    delta = abs(frequency - actual_frequency)

    print("multiple:", i, " actual_frequency:",
          actual_frequency, " lenght:", lenght)

    if delta < lowes_delta:
        lowes_delta = delta
        best_multiple = i

# calculate best result
lenght = round(sampling_rate*best_multiple/frequency)
actual_frequency = sampling_rate*best_multiple / lenght
delta = frequency - actual_frequency

print("\nBest result:")
print("multiple:", best_multiple, " actual_frequency:",
      actual_frequency, " lenght:", lenght)

data = []
x = np.linspace(0, lenght-1, lenght)
# y = np.sin(x)

for i in range(0, lenght):
    index = i * (best_multiple / lenght) * (2*np.pi)
    data.append(np.sin(index) * max_amplitude)


def int_to_twos(num, bits):
    mask = (1 << bits) - 1
    return "{:0{}b}".format(num & mask, bits)


def write_to_file():
    f = open(file_name, "w")

    f.write(int_to_twos(lenght, 24))
    f.write("\n")
    for i in range(0, lenght):
        f.write(int_to_twos(round(data[i]), 24))
        f.write("\n")

    f.close


def plot_data():
    plt.title("two periods with multiple")
    plt.scatter(x, data, color='b')
    plt.plot(data, color='b')
    plt.scatter((x+lenght), data, color='r')
    plt.plot((x+lenght), data, color='r')

    plt.show()


plot_data()
write_to_file()
