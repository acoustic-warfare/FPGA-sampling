from ast import For
import numpy as np
import math
import matplotlib.pyplot as plt
from pathlib import Path
#import config
import os

def load_data_BB(filename):
    # OLD FUNCTION TO LOAD DATA FROM BEAGELBONE
    #filename = 'calibration_signals_array1'
    #path = Path('/home/batman/BatSignal/Batprogram/calibration/calibration_data/' + filename + '.bin.txt')
    #path = Path('/home/batman/BatSignal/data/studion1506/' + filename + 'txt')
    ROOT = os.getcwd()
    path = Path(ROOT + "/mic_data/delay_.txt")

    # Load calibration data from file
    data = np.loadtxt(open(path,'rb'),delimiter=',')
    f_sampling = data[0,0]  # sampling frequency
    data = data[:,2:66]
    return data, f_sampling

def load_data_FPGA(filename):
    #   FUNCTION TO LOAD DATA FROM .TXT FILE INTO NUMPY ARRAY 
    #   (RECORDED BY FPGA)
    ROOT = os.getcwd()
    path = Path(ROOT +"/ps/mic_data/delay_.txt")

#"/mic_data/delay_.txt"
    # Load recorded data from file
    data = np.loadtxt(open(path,'rb').readlines()[:-1],delimiter=',')
    f_sampling = 48828 # get sampling frequency
    data = data[:,4:]       # take out data from microphones only

    # Order of microphones, to make it compatible with beamforming algoritms
    #order = np.array([57, 58, 59, 60, 61, 62, 63, 64, \
    #56, 55, 54, 53, 52, 51, 50, 49, \
    #41, 42, 43, 44, 45, 46, 47, 48, \
    #40, 39, 38, 37, 36, 35, 34, 33, \
    #25, 26, 27, 28, 29, 30, 31, 32, \
    #24, 23, 22, 21, 20, 19, 18, 17, \
    #9, 10, 11, 12, 13, 14, 15, 16, \
    #8, 7, 6, 5, 4, 3, 2, 1], dtype=int)-1

    order = np.array([1, 2, 3, 4, 5, 6, 7, 8, \
    9, 10, 11, 12, 13, 14, 15, 16, \
    17, 18, 19, 20, 21, 22, 23, 24, \
    25, 26, 27, 28, 29, 30, 31, 32, \
    33, 34, 35, 36, 37, 38, 39, 40, \
    41, 42, 43, 44, 45, 46, 47, 48, \
    49, 50, 51, 52, 53, 54, 55, 56, \
   57, 58, 59, 60, 61, 62, 63, 64], dtype=int)-1

    # Rearrange microphone signals after correct order
    #data = data[:,order] 

    return data, int(f_sampling)

def delete_mic_data(signal, mic_to_delete):
    #   FUNCTION THAT SETS SIGNALS FROM 'BAD' MICROPHONES TO 0
    for mic in range(len(mic_to_delete)):
        for samp in range(len(signal[:,0])):
            signal[samp,mic_to_delete[mic]] = 0
    return signal

def write_to_file(write, filename, values):
    #   FUNCTION THAT WRITES VALUES TO .TXT FILE
    np.savetxt(filename, values, delimiter=',\t ', newline='\n', header='', footer='', comments='# ', encoding=None)


def main():
    recording_device = 'FPGA' # choose between 'FPGA' and 'BB' (BeagelBone) 
    filename = 'new_sample_data_new'

    initial_samples = 10000                 # initial samples, at startup phase of Beaglebone recording

    # Choose the mic signals that should be set to zero
    mics_to_delete = [8, 38]
    arr_mics_to_delete = np.array(mics_to_delete, dtype = int)-1 # converts mic_to_delete to numpy array with correct index

    # Plot options
    plot_period = 1     # periods to plot
    f0 = 440           # frequency of recorded sinus signal
    normalized = 0      # if normalized = 1, the signals will be normalized according to the maximum value recorded

    # Load data from .txt file
    if recording_device == 'FPGA':
        data, fs = load_data_FPGA(filename)
    elif recording_device == 'BB':
        data, fs = load_data_BB(filename)
    total_samples = len(data[:,0])          # Total number of samples
    initial_data = data[0:initial_samples,] # takes out initial samples of signals 

    new_lab_data = 0
    for i in range(0,64):
      new_lab_data = np.add(new_lab_data,data[:,i])

    new_lab_data = new_lab_data/64

    print(len(new_lab_data))

    lab_test_mic = 1;
    initial_lab_test_sample = 10000;
    lab_test_samples = 5000;
    lab_test_data = data[initial_lab_test_sample:initial_lab_test_sample+lab_test_samples,lab_test_mic];
    lab_test_power = np.sum(np.abs(lab_test_data)* np.abs(lab_test_data))/lab_test_samples /pow(2,23)
    print(lab_test_power)

    if recording_device == 'FPGA':
        ok_data = data[1000:,] # all data is ok
    elif recording_device == 'BB':
        ok_data = data[initial_samples:,] # initial startup values are ignored


    plot_samples = math.floor(plot_period*(fs/f0))                     # number of samples to plot, to use for axis scaling
    max_value_ok = np.max(np.max(ok_data[0:4000,],axis=0)) # maximum value of data, to use for axis scaling in plots

    print('f_sampling: '+ str(int(fs)))

    # --- PLOT ---
    #   of bad microphones
    plt.figure()
    for mic in range(len(arr_mics_to_delete)):
        plt.plot(ok_data[:,arr_mics_to_delete[mic]])
    plt.xlim([0, plot_samples])
    plt.xlabel('Samples')
    plt.ylabel('Amplitude')
    plt.title('Bad microphones')
    if normalized:
      plt.ylim([-max_value_ok*1.1, max_value_ok*1.1])


    # --- PLOT ---
    #   of all individual signals in subplots, two periods
    fig, axs = plt.subplots(4,16)
    fig.suptitle("Individual signals", fontsize=16)
    start_val = 4000
    for j in range(4):
        for i in range(16):
            axs[j,i].plot(ok_data[start_val:start_val+plot_samples,i+j*16])
            axs[j,i].set_title(str(i+j*16+1), fontsize=8)
            axs[j,i].axis('off')
            if normalized:
               axs[j,i].set_ylim(-max_value_ok*1.1, max_value_ok*1.1)

    # Set microphone signals of bad mics to zero
    #clean_data = delete_mic_data(ok_data, arr_mics_to_delete)
    #clean_initial_data = delete_mic_data(initial_data, arr_mics_to_delete)

    # --- PLOT ---
    #   plot of all microphones, after bad signals have been set to 0
    plt.figure()
    plt.plot(ok_data)
    plt.xlim([0, plot_samples])
    plt.xlabel('Samples')
    plt.ylabel('Amplitude')
    plt.suptitle('All microphones')
    if normalized:
      plt.ylim([-max_value_ok*1.1, max_value_ok*1.1])
    
    # --- PLOT ---
    #   of selected microphones
    plot_mics = [1, 2, 3, 4, 6, 7, 8,  
   57, 58, 59, 60, 61, 62, 63, 64]                     # what microphones to plot
    arr_plot_mics = np.array(plot_mics)-1   # convert plot_mics to numpy array with correct index
    mic_legend = []                         # empty list that should hold legends for plot
    plt.figure()
    for i in range(len(arr_plot_mics)):
        plt.plot(ok_data[:,int(arr_plot_mics[i])], '-*')
        mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
    plt.xlim([0, plot_samples])
    plt.xlabel('Samples')
    plt.ylabel('Amplitude')
    plt.suptitle('Selected microphones microphones')
    plt.legend(mic_legend)
    if normalized:
      plt.ylim([-max_value_ok*1.1, max_value_ok*1.1])

    # --- PLOT ---
    plt.figure()
    plt.plot(initial_data[:,3])
    plt.plot(new_lab_data)
    plt.xlim([0, initial_samples])
    plt.xlabel('Samples')
    plt.ylabel('Amplitude')
    plt.suptitle('Initial values')

    # --- PLOT ---
    #   of FFT of one signal
    mic = 1         # mic signals of FFT
    samples = len(ok_data[:,0])
    t_stop = samples/fs
    t = np.linspace(0,t_stop,samples)
    data_FFT = np.fft.fft(ok_data[:,mic-1])
    energy = abs(data_FFT)**2
    freq = np.fft.fftfreq(t.shape[-1])
    plt.figure()
    plt.plot(fs*freq,energy)
    plt.title('Energy of signal')
    plt.xlabel('Frequency [Hz]')
    plt.legend(str(mic))

    
    # --- PLOT ---
    #   of FFT of several signals
    mics_FFT = [1,2,15,16]
    arr_mics_FFT = np.array(mics_FFT,dtype=int)-1
    FFT_mic_legend = []                         # empty list that should hold legends for plot
    plt.figure()
    for i in range(len(arr_mics_FFT)):
        data_FFT = np.fft.fft(ok_data[:,int(arr_mics_FFT[i])])
        energy = abs(data_FFT)**2
        freq = np.fft.fftfreq(t.shape[-1])
        plt.plot(fs*freq,energy)
        FFT_mic_legend = np.append(FFT_mic_legend,str(arr_mics_FFT[i]+1))
    plt.suptitle('Energy of selected microphones signals')
    plt.xlabel('Frequency [Hz]')
    plt.legend(FFT_mic_legend)


    # Show all plots
    plt.show()

main()
