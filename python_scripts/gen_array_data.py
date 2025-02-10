import numpy as np
import matplotlib.pyplot as plt

sampling_rate = 48828.125  # (FPGA sampling rate) [Hz]

######################
# START USER PARAMETERS

# Max BRAM (with some headroom :))
# If I imporve this to the max run from 1 to 60000 samples
BRAM_max_size = 60000  # max nr samples

# Desired frequency [Hz]
# min frequency that will work good is around 10 Hz?
frequencys = [400, 1500]

# Noise level (% of max_amplitude or db or something)
# Mabey it should be SNR instead
noise_level = 0  # todo add this feature

# Max amplitude of output
# 24 bit signed means max is 8388607
max_amplitude = 1000

file_name_sim = "./data.mem"
file_name_build = "./pl/src/simulated_array/data.mem"

# END USER PARAMETERS
####################


def ramp_signal():
    length = 100
    data = []
    for i in range(length):
        data.append(i)

    # first print have to be lenght for the build.sh script to work
    print(length)

    return length, data


def zero_signal():
    length = 100
    data = []
    for i in range(length):
        data.append(0)

    # first print have to be lenght for the build.sh script to work
    print(length)

    return length, data


def sinus_signals():
    # try all multiples and see which is best
    # in reality you only need to test prime multiples, rest are useless
    best_delta = 9999
    length = 1
    for i in range(1, BRAM_max_size):
        all_deltas = []
        for frequency in frequencys:

            multiple = round(i * frequency/sampling_rate)

            actual_frequency = sampling_rate * multiple / i
            delta = abs(frequency - actual_frequency)
            all_deltas.append(delta)

        if (best_delta > np.max(all_deltas)):
            best_delta = delta
            length = i

    final_frequencys = []
    final_delats = []
    for frequency in frequencys:

        multiple = round(length * frequency/sampling_rate)

        actual_frequency = sampling_rate * multiple / length
        delta = abs(frequency - actual_frequency)

        final_frequencys.append(actual_frequency)
        final_delats.append(delta)

    worst_delta = np.max(final_delats)
    print(length)  # first print have to be lenght for the build.sh script to work
    print("worst_delta:", best_delta, " [Hz]")
    print("length: ", length)
    print("desired_frequnecys: ", frequencys)  # make this x decimans
    print("actual_frequnecys: ", final_frequencys)  # make this x decimans

    x = np.linspace(0, length-1, length)

    all_data_components = []
    for frequency in final_frequencys:
        data_component = []
        for i in range(0, length):
            index = i * (frequency / sampling_rate) * (2*np.pi)
            amplitude = np.sin(index)
            data_component.append(amplitude)

        all_data_components.append(data_component)

    data = []
    for i in range(0, length):
        amplitude = 0
        for data_component in all_data_components:
            amplitude = amplitude + data_component[i]

        data.append(amplitude)

    # Amplification
    max_natural_amplitude = max(data)
    amplification = max_amplitude / max_natural_amplitude
    data = np.array(data) * amplification
    all_data_components = np.array(all_data_components) * amplification
    print("max_natural_amplitude", max_natural_amplitude)

    return length, data


def plt_freq_component(all_data_components, index):
    plt.plot(all_data_components[index])


def plt_all_freq_components(all_data_components, final_frequencys):
    for i in range(len(final_frequencys)):
        plt_freq_component(all_data_components, i)


def int_to_twos(num, bits):
    mask = (1 << bits) - 1
    return "{:0{}b}".format(num & mask, bits)


def save_sample_data_to_file(file_name, length, samples):
    f = open(file_name, "w")
    # f.write(int_to_twos(length, 24))
    # f.write("\n")
    for i in range(0, length):
        f.write(int_to_twos(round(samples[i]), 24))
        f.write("\n")

    f.close


# length, data = sinus_signals()
# length, data = ramp_signal()
length, data = zero_signal()


save_sample_data_to_file(file_name_build, length, data)
save_sample_data_to_file(file_name_sim, length, data)

# plt_all_freq_components(all_data_components, final_frequencys)
# plt.plot(data, color='r')
# plt.xlim(0, 122)
# plt.show()
