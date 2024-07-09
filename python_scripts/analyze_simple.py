import numpy as np
import os
from pathlib import Path
import matplotlib.pyplot as plt


def load_data_FPGA(fileChooser):
    ROOT = os.getcwd()
    path = Path(ROOT + "/" + fileChooser)
    data = np.fromfile(path, dtype=np.int32, count=-1, offset=0)
    data2D = data.reshape(-1, 258)
    micData = data2D[:, 2:]
    f_sampling = 48828
    return micData, f_sampling


def plot_mic_data(fileChooser):
    mic1 = 17
    mic2 = 81

    data, fs = load_data_FPGA(fileChooser)

    # FFT for microphone 17
    mic_data_17 = data[:, mic1 - 1]
    n_17 = len(mic_data_17)
    fft_result_17 = np.fft.fft(mic_data_17)
    freq_17 = np.fft.fftfreq(n_17, d=1 / fs)
    freq_17 = freq_17[: n_17 // 2]  # Take only positive frequencies
    fft_result_17 = (
        np.abs(fft_result_17[: n_17 // 2]) / n_17
    )  # Normalize by number of samples

    # FFT for microphone 81
    mic_data_81 = data[:, mic2 - 1]
    n_81 = len(mic_data_81)
    fft_result_81 = np.fft.fft(mic_data_81)
    freq_81 = np.fft.fftfreq(n_81, d=1 / fs)
    freq_81 = freq_81[: n_81 // 2]  # Take only positive frequencies
    fft_result_81 = (
        np.abs(fft_result_81[: n_81 // 2]) / n_81
    )  # Normalize by number of samples

    # Find indices corresponding to frequency range 0 to 2000 Hz
    idx_17 = np.where((freq_17 >= 0) & (freq_17 <= 2000))[0]
    idx_81 = np.where((freq_81 >= 0) & (freq_81 <= 2000))[0]
    max_amplitude_17 = np.max(fft_result_17[idx_17])
    max_amplitude_81 = np.max(fft_result_81[idx_81])

    fft_result_17_normalized = fft_result_17 / max_amplitude_17
    fft_result_81_normalized = fft_result_81 / max_amplitude_81

    # Plot frequency-domain signal (FFT) for microphone 17
    plt.subplot(3, 1, 1)
    plt.plot(
        freq_17, fft_result_17_normalized, color="blue", label=f"Microphone {mic1}"
    )
    plt.title("Frequency Spectrum of Microphone Signals")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Amplitude (Normalized)")
    plt.xlim(0, 2000)  # Limit x-axis to positive frequencies
    plt.ylim(0, 1)  # Set y-axis limit to max amplitude
    plt.legend()

    # Plot frequency-domain signal (FFT) for microphone 81
    plt.subplot(3, 1, 2)
    plt.plot(
        freq_81, fft_result_81_normalized, color="green", label=f"Microphone {mic2}"
    )
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Amplitude (Normalized)")
    plt.xlim(0, 2000)  # Limit x-axis to positive frequencies
    plt.ylim(0, 1)  # Set y-axis limit to max amplitude
    plt.legend()

    # Plot both on the same subplot for comparison
    plt.subplot(3, 1, 3)
    plt.plot(
        freq_17, fft_result_17_normalized, color="blue", label=f"Microphone {mic1}"
    )
    plt.plot(
        freq_81, fft_result_81_normalized, color="green", label=f"Microphone {mic2}"
    )
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Amplitude (Normalized)")
    plt.xlim(0, 2000)  # Limit x-axis to positive frequencies
    plt.ylim(0, 1)  # Set y-axis limit to max amplitude
    plt.legend()

    # Adjust layout to ensure plots do not overlap
    plt.tight_layout()

    plt.show()


if __name__ == "__main__":
    print("Enter a filename to samples: ")
    fileChooser = input()
    plot_mic_data(fileChooser)
