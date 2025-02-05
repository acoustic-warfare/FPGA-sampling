
# mic 35 works good on the "Bäst! 20223-09-21 array" and is in the midle of the array

import numpy as np
import os
from pathlib import Path
import matplotlib.pyplot as plt


def load_data_FPGA(fileChooser):
    ROOT = os.getcwd()
    path = Path(ROOT + "/recorded_data/" + fileChooser + ".bin")
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 66)  # 1array (-1, 66), 4arrays (-1, 258)
    micData = data2D[:, 2:]
    f_sampling = 48828.125
    return micData, f_sampling


def plot_mic_data_fft(fileChooser, mic_nr, max_freq):
    data, fs = load_data_FPGA(fileChooser)

    # FFT for microphone
    mic_data = data[:, mic_nr - 1]
    n = len(mic_data)
    fft_result = np.fft.fft(mic_data)
    freq = np.fft.fftfreq(n, d=1 / fs)
    freq = freq[: n // 2]  # Take only positive frequencies
    fft_result = (
        np.abs(fft_result[: n // 2]) / n
    )  # Normalize by number of samples

    # Find indices corresponding to frequency range 0 to max_freq Hz
    idx = np.where((freq >= 0) & (freq <= max_freq))[0]
    max_amplitude = np.max(fft_result[idx])

    fft_result_normalized = fft_result / max_amplitude

    # Plot frequency-domain signal (FFT) for microphone
    plt.subplot(2, 1, 1)
    plt.plot(
        freq, fft_result_normalized, color="blue", label=f"Microphone {mic_nr}"
    )
    plt.title("Frequency Spectrum of Microphone Signals")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Amplitude (Normalized)")
    plt.xlim(0, max_freq)  # Limit x-axis to positive frequencies
    plt.ylim(0, 1.2)  # Set y-axis limit to max amplitude
    plt.legend()


def plot_mic_data(fileChooser, mic_nr, max_time):
    data, fs = load_data_FPGA(fileChooser)
    mic_data = data[:, mic_nr - 1]
    length = len(mic_data)
    print("Recoring length (samples): ", length,
          "     Recoring length (seconds): ", length/fs)
    x = np.linspace(0, length-1, length)

    # Plot frequency-domain signal (FFT) for microphone
    plt.subplot(2, 1, 2)
    plt.scatter(x, mic_data, color="blue", label=f"Mic {mic_nr}")
    plt.title("Microphone Signal (time domain)")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Amplitude (Normalized)")
    plt.xlim(0, max_time*fs)  # Limit x-axis to positive frequencies
    # plt.ylim(0, 1)  # Set y-axis limit to max amplitude
    plt.legend()


print("Enter a file to plot: ")
fileChooser = input()
# fileChooser = "test"

mic_nr = 35
# max_frequency = 48828.125/2

# todo would be nice with some sub plot situation :)
plot_mic_data_fft(fileChooser, mic_nr=mic_nr, max_freq=4000)
plot_mic_data(fileChooser, mic_nr=mic_nr, max_time=1)
plt.show()

print(" ")  # end with a empty line
