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
    freq_17 = np.fft.fftfreq(n_17, d=1/fs)
    freq_17 = freq_17[:n_17//2]  # Take only positive frequencies
    fft_result_17 = np.abs(fft_result_17[:n_17//2]) / n_17  # Normalize by number of samples

    # FFT for microphone 81
    mic_data_81 = data[:, mic2 - 1]
    n_81 = len(mic_data_81)
    fft_result_81 = np.fft.fft(mic_data_81)
    freq_81 = np.fft.fftfreq(n_81, d=1/fs)
    freq_81 = freq_81[:n_81//2]  # Take only positive frequencies
    fft_result_81 = np.abs(fft_result_81[:n_81//2]) / n_81  # Normalize by number of samples

    # Plot frequency-domain signal (FFT) for microphone 17
    plt.figure(figsize=(12, 6))
    plt.subplot(2, 1, 1)
    plt.plot(freq_17, fft_result_17)
    plt.title(f"Frequency Spectrum of Microphone {mic1} Signal")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Amplitude")
    plt.xlim(0, 2000)  # Limit x-axis to positive frequencies
    plt.tight_layout()

    # Plot frequency-domain signal (FFT) for microphone 81
    plt.subplot(2, 1, 2)
    plt.plot(freq_81, fft_result_81)
    plt.title(f"Frequency Spectrum of Microphone {mic2} Signal")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Amplitude")
    plt.xlim(0, 2000)  # Limit x-axis to positive frequencies

    plt.show()

if __name__ == "__main__":
    print("Enter a filename to samples: ")
    fileChooser = input()
    plot_mic_data(fileChooser)
