from ctypes import c_int32
import numpy as np
import math
import matplotlib.pyplot as plt
from pathlib import Path
from ctypes import c_int32
import os

nr_arrays = 2  # todo: make this find the nr_arrays from the header :)
expected_columns = nr_arrays * 64 + 2


def print_analysis(fileChooser, microphones, source_audio):

    def load_data_FPGA():

        ROOT = os.getcwd()
        path = Path(ROOT + "/" + fileChooser)

        data = np.fromfile(
            path, dtype=c_int32, count=-1, offset=0
        )  # Read the whole file
        # reshapes into a Numpy array which is N*68 in dimensions

        data2D = data.reshape(-1, expected_columns)
        micData = data2D[:, 2:]  # removes headerinformation
        # f_sampling = np.fromfile(path,dtype=c_int32,count=1,offset=8) # get sampling frequency from the file
        f_sampling = 48828
        return micData, int(f_sampling)

    def main():
        # choose between 'FPGA' and 'BB' (BeagelBone)
        recording_device = "FPGA"
        fs = 48828

        # initial samples, at startup phase of Beaglebone recording
        initial_samples = 10000

        # Choose the mic signals that should be set to zero
        # mics_to_delete = [8, 38]
        # arr_mics_to_delete = np.array(mics_to_delete, dtype = int)-1 # converts mic_to_delete to numpy array with correct index

        # Plot options
        plot_period = 1  # periods to plot
        f0 = int(source_audio)  # frequency of recorded sinus signal
        # if normalized = 1, the signals will be normalized according to the maximum value recorded
        normalized = 0

        # Load data from .txt file
        if recording_device == "FPGA":
            data, fs = load_data_FPGA()
        total_samples = len(data[:, 0])  # Total number of samples
        # takes out initial samples of signals
        initial_data = data[0:initial_samples,]

        new_lab_data = 0
        for i in range(0, 64):
            new_lab_data = np.add(new_lab_data, data[:, i])

        new_lab_data = new_lab_data / 64
        print("################# ANALYSE OF " + fileChooser + " #################")

        lab_test_mic = 1
        initial_lab_test_sample = 10000
        lab_test_samples = 5000
        lab_test_data = data[
            initial_lab_test_sample : initial_lab_test_sample + lab_test_samples,
            lab_test_mic,
        ]
        lab_test_power = (
            np.sum(np.abs(lab_test_data) * np.abs(lab_test_data))
            / lab_test_samples
            / pow(2, 23)
        )
        print("power: " + str(lab_test_power))

        staring_point = 1000  # default = 1000

        if recording_device == "FPGA":
            ok_data = data[staring_point:,]  # all data is ok

        # number of samples to plot, to use for axis scaling
        plot_samples = math.floor(plot_period * (fs / f0) * 2)
        # maximum value of data, to use for axis scaling in plots
        max_value_ok = np.max(np.max(ok_data[0:4000,], axis=0))

        print("sample frequency: " + str(int(fs)))

        # Plot of all individual signals in subplots, two periods
        fig, axs = plt.subplots(4, 16)
        fig.suptitle("Individual signals 1-64", fontsize=16)
        start_val = 4000

        for j in range(4):
            for i in range(16):
                axs[j, i].plot(
                    ok_data[start_val : start_val + plot_samples, i + j * 16]
                )
                axs[j, i].set_title(str(i + j * 16 + 1), fontsize=8)
                axs[j, i].axis("off")
                if normalized:
                    axs[j, i].set_ylim(-max_value_ok * 1.1, max_value_ok * 1.1)

        if nr_arrays > 1:
            fig, axs = plt.subplots(4, 16)
            fig.suptitle("Individual signals 65-128", fontsize=16)

            for j in range(4):
                for i in range(16):
                    axs[j, i].plot(
                        ok_data[start_val : start_val + plot_samples, i + j * 16 + 64]
                    )
                    axs[j, i].set_title(str(i + j * 16 + 1 + 64), fontsize=8)
                    axs[j, i].axis("off")
                    if normalized:
                        axs[j, i].set_ylim(-max_value_ok * 1.1, max_value_ok * 1.1)

        if nr_arrays > 2:
            fig, axs = plt.subplots(4, 16)
            fig.suptitle("Individual signals 129-192", fontsize=16)
            start_val = 4000

            for j in range(4):
                for i in range(16):
                    axs[j, i].plot(
                        ok_data[start_val : start_val + plot_samples, i + j * 16 + 128]
                    )
                    axs[j, i].set_title(str(i + j * 16 + 1 + 128), fontsize=8)
                    axs[j, i].axis("off")
                    if normalized:
                        axs[j, i].set_ylim(-max_value_ok * 1.1, max_value_ok * 1.1)

        if nr_arrays > 2:
            fig, axs = plt.subplots(4, 16)
            fig.suptitle("Individual signals 193-256", fontsize=16)
            start_val = 4000

            for j in range(4):
                for i in range(16):
                    axs[j, i].plot(
                        ok_data[start_val : start_val + plot_samples, i + j * 16 + 192]
                    )
                    axs[j, i].set_title(str(i + j * 16 + 1 + 192), fontsize=8)
                    axs[j, i].axis("off")
                    if normalized:
                        axs[j, i].set_ylim(-max_value_ok * 1.1, max_value_ok * 1.1)

        # Show all plots
        plt.show()

    main()


#################################################################################################
print("Enter a filename to samples: ")
fileChooser = input()
# fileChooser = "ljud"
print("Enter the frequency of the audio source (Hz): ")
# source_audio=input()
source_audio = 440
microphones = [0]

print_analysis(fileChooser, microphones, source_audio)
