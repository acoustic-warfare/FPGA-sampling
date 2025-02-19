import numpy as np
import matplotlib.pyplot as plt

sampling_rate = 48828.125  # (FPGA sampling rate) [Hz]

######################
# START USER PARAMETERS

# Max BRAM (with some headroom :))
# If I imporve this to the max run from 1 to 60000 samples
BRAM_max_size = 1000000  # max nr samples

# Desired frequency [Hz]
# min frequency that will work good is around 10 Hz?
frequencies = [200, 15000]

# Noise level (% of max_amplitude or db or something)
# Mabey it should be SNR instead
noise_level = 0  # todo add this feature

# Max amplitude of output
# 24 bit signed means max is 8388607
max_amplitude = 100

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
        for frequency in frequencies:

            multiple = round(i * frequency/sampling_rate)

            actual_frequency = sampling_rate * multiple / i
            delta = abs(frequency - actual_frequency)
            all_deltas.append(delta)

        if (best_delta > np.max(all_deltas)):
            best_delta = delta
            length = i

    final_frequencies = []
    final_delats = []
    for frequency in frequencies:

        multiple = round(length * frequency/sampling_rate)

        actual_frequency = sampling_rate * multiple / length
        delta = abs(frequency - actual_frequency)

        final_frequencies.append(actual_frequency)
        final_delats.append(delta)

    worst_delta = np.max(final_delats)
    print(length)  # first print have to be lenght for the build.sh script to work
    print("worst_delta:", worst_delta, " [Hz]")
    print("length: ", length)
    print("desired_frequnecys: ", frequencies)  # make this x decimans
    print("actual_frequnecys: ", final_frequencies)  # make this x decimans

    all_data_components = []
    for frequency in final_frequencies:
        data_component = []
        for i in range(0, length):
            index = i * (frequency / sampling_rate) * (2*np.pi)
            amplitude = np.sin(index)
            data_component.append(amplitude)

        all_data_components.append(data_component)

    data_raw = []
    for i in range(0, length):
        amplitude = 0
        for data_component in all_data_components:
            amplitude = amplitude + data_component[i]

        data_raw.append(amplitude)

    # Amplification
    max_natural_amplitude = max(data_raw)
    amplification = max_amplitude / max_natural_amplitude
    data = np.array(data_raw) * amplification

    return length, data, final_frequencies


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


def plt_freq_fft(data, length):
    """Compute and plot the FFT of two signals in separate subplots."""
    Fs = 48828.125
    freq_axis = np.fft.fftfreq(length, d=1/Fs)[:length//2]  # Compute positive frequencies

    # Apply Hanning window to reduce spectral leakage
    window = np.hanning(length)
    data = data * window

    # Compute FFT magnitude (normalize for comparison)
    fft_0 = np.fft.fft(data)
    magnitude_0 = 20 * np.log10(np.abs(fft_0[:length//2]) + 1e-12)  # Avoid log(0)

    plt.figure(figsize=(10, 6))
    plt.plot(freq_axis, magnitude_0, color="b")
    # qplt.ylim(bottom=0)
    plt.ylabel("Magnitude (dB)")
    plt.grid()

    plt.tight_layout()
    plt.show()


length, data, final_frequencies = sinus_signals()
# length, data = ramp_signal()
# length, data = zero_signal()


save_sample_data_to_file(file_name_build, length, data)
save_sample_data_to_file(file_name_sim, length, data)

plt_freq_fft(data, length)
