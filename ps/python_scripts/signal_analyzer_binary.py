from ast import For
import numpy as np
import math
import struct
import matplotlib.pyplot as plt
from pathlib import Path
from ctypes import Structure, c_byte, c_int32, sizeof
#import config
import os


def load_data_FPGA(filename):
    #   FUNCTION TO LOAD DATA FROM .TXT FILE INTO NUMPY ARRAY 
    #   (RECORDED BY FPGA)

    print("Enter file to analyze: ")
    fileChooser=input()
    ROOT = os.getcwd()
    path = Path(ROOT + "/"+fileChooser)
 
    data = np.fromfile(path,dtype=c_int32,count=-1,offset=0) #Read the whole file
    data2D = data.reshape(-1,68)  # reshapes into a Numpy array which is N*68 in dimensions
    
    ## Data2D holds all information from the file.
    ## Data2D[n][0] = array id
    ## Data2D[n][1] = protocol version
    ## Data2D[n][2] = frequency
    ## Data2D[n][3] = array sample counter
    ## Data2D[n][4] to  Data2D[n][63] = is microphone 1 to 64

    

    micData = data2D[:,4:] #An array with only mic data. i.e removes (Array id, protocol version, freq and counter)
    f_sampling = np.fromfile(path,dtype=c_int32,count=1,offset=8) # get sampling frequency from the file
  
    return micData, int(f_sampling),fileChooser

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
    #mics_to_delete = [8, 38]
    #arr_mics_to_delete = np.array(mics_to_delete, dtype = int)-1 # converts mic_to_delete to numpy array with correct index

    # Plot options
    plot_period = 1     # periods to plot
    f0 = 440           # frequency of recorded sinus signal
    normalized = 0      # if normalized = 1, the signals will be normalized according to the maximum value recorded

    # Load data from .txt file
    if recording_device == 'FPGA':
        data, fs,fileChooser = load_data_FPGA(filename)
    total_samples = len(data[:,0])          # Total number of samples
    initial_data = data[0:initial_samples,] # takes out initial samples of signals 

    new_lab_data = 0
    for i in range(0,64):
      new_lab_data = np.add(new_lab_data,data[:,i])

    new_lab_data = new_lab_data/64
    print("################# ANALYSIS OF "+ fileChooser+" #################")
    print("\n")
    print("total nr samples in file: "+str(len(new_lab_data)))
    

    lab_test_mic = 1;
    initial_lab_test_sample = 10000;
    lab_test_samples = 5000;
    lab_test_data = data[initial_lab_test_sample:initial_lab_test_sample+lab_test_samples,lab_test_mic];
    lab_test_power = np.sum(np.abs(lab_test_data)* np.abs(lab_test_data))/lab_test_samples /pow(2,23)
    print("power: "+str(lab_test_power))

    if recording_device == 'FPGA':
        ok_data = data[1000:,] # all data is ok


    plot_samples = math.floor(plot_period*(fs/f0))                     # number of samples to plot, to use for axis scaling
    max_value_ok = np.max(np.max(ok_data[0:4000,],axis=0)) # maximum value of data, to use for axis scaling in plots

    print('sample frequency: '+ str(int(fs)))

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
