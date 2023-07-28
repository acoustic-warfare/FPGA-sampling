import itertools
import logging
import socket
import sys
import struct
import time
from ctypes import Structure, c_byte, c_int32, sizeof
from ast import For
import numpy as np
import math
import struct
import matplotlib.pyplot as plt
from pathlib import Path
from ctypes import Structure, c_byte, c_int32, sizeof
# import config
import os
from scipy.io.wavfile import write
from scipy import signal
from scipy.signal import butter, filtfilt, correlate, chirp, welch, periodogram, sosfilt
# This scripts listen on an port and collects array samples and then plots the graphs direcly!
# Enter a filename and how long you want to record.
# Pick a horizontal line or a vertical line.
# the plotted graphs will show
# to make a new recording simply close all the graphs and a new session is started.


def collect_samples(filename, recordTime):
    # NOTE: Check if big-endian or little-endian as this is often flipped
    # use:
    # from ctypes import LittleEndianStructure, BigEndianStructure
    # and replace Structure with LittleEndianStructure or BigEndianStructure to get the right one.
    class Data(Structure):
        _fields_ = [
            ("arrayId", c_int32),
            ("protocolVer", c_int32),  # The data we care about
            ("frequency", c_int32),
            ("sampelCounter", c_int32),
            ("mic_1", c_int32), ("mic_2", c_int32), ("mic_3", c_int32), ("mic_4", c_int32), ("mic_5", c_int32), ("mic_6", c_int32), ("mic_7", c_int32), ("mic_8", c_int32), ("mic_9", c_int32), 
            ("mic_10", c_int32), ("mic_11", c_int32), ("mic_12", c_int32), ("mic_13", c_int32), ("mic_14", c_int32), ("mic_15", c_int32), ("mic_16", c_int32),
            ("mic_17", c_int32), ("mic_18", c_int32), ("mic_19", c_int32), ("mic_20", c_int32), ("mic_21", c_int32), ("mic_22", c_int32), ("mic_23", c_int32), ("mic_24", c_int32), (
                "mic_25", c_int32), ("mic_26", c_int32), ("mic_27", c_int32), ("mic_28", c_int32), ("mic_29", c_int32), ("mic_30", c_int32), ("mic_31", c_int32), ("mic_32", c_int32),
            ("mic_33", c_int32), ("mic_34", c_int32), ("mic_35", c_int32), ("mic_36", c_int32), ("mic_37", c_int32), ("mic_38", c_int32), ("mic_39", c_int32), ("mic_40", c_int32), ("mic_41", c_int32), ("mic_42", c_int32), ("mic_43", c_int32), ("mic_44", c_int32), ("mic_45", c_int32), ("mic_46", c_int32), ("mic_47", c_int32), ("mic_48", c_int32), (
                "mic_49", c_int32), ("mic_50", c_int32), ("mic_51", c_int32), ("mic_52", c_int32), ("mic_53", c_int32), ("mic_54", c_int32), ("mic_55", c_int32), ("mic_56", c_int32), ("mic_57", c_int32), ("mic_58", c_int32), ("mic_59", c_int32), ("mic_60", c_int32), ("mic_61", c_int32), ("mic_62", c_int32), ("mic_63", c_int32), ("mic_64", c_int32),
        ]
    UDP_IP = "0.0.0.0"
    UDP_PORT = 21844

    t_end = time.time()+int(recordTime)

    """Receive packages forever"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((UDP_IP, UDP_PORT))

    # itertools.count() is a generator that counts up forever.
    # same as while True with the added benefit of keeping track of the number of iterations.
    # Can be converted to a while True if count is unused.
    with open(filename, "wb") as f:

        # for count in itertools.count():
        while time.time() < t_end:
            data = sock.recv(sizeof(Data))

            d = Data.from_buffer_copy(data)
            f.write(d)
    f.close
    sys.stdout.flush()


def print_analysis(fileChooser):

    def load_data_FPGA():
        #   FUNCTION TO LOAD DATA FROM .BIN FILE INTO NUMPY ARRAY
        #   (RECORDED BY FPGA)

        ROOT = os.getcwd()
        path = Path(ROOT + "/"+fileChooser)

        data = np.fromfile(path, dtype=c_int32, count=-1,
                           offset=0)  # Read the whole file
        # reshapes into a Numpy array which is N*68 in dimensions
        data2D = data.reshape(-1, 68)

        # Data2D holds all information from the file.
        # Data2D[n][0] = array id
        # Data2D[n][1] = protocol version
        # Data2D[n][2] = frequency
        # Data2D[n][3] = array sample counter
        # Data2D[n][4] to  Data2D[n][67] = is microphone 1 to 64

        # An array with only mic data. i.e removes (Array id, protocol version, freq and counter)
        micData = data2D[:, 4:]
        # get sampling frequency from the file
        f_sampling = np.fromfile(path, dtype=c_int32, count=1, offset=8)
        # f_sampling = 10000
        return micData, int(f_sampling), fileChooser

    def main():
        # choose between 'FPGA' and 'BB' (BeagelBone)
        recording_device = 'FPGA'

        # Load data from .BIN
        if recording_device == 'FPGA':
            data, fs, fileChooser = load_data_FPGA()
        # total_samples = len(data[:,0])          # Total number of samples
        # initial_data = data[0:initial_samples,] # takes out initial samples of signals

        print("################# ANALYSE OF " +
              fileChooser+" #################")
        print("\n")
        print('sample frequency: ' + str(int(fs)))

        staring_point = 1000  # default = 1000

        if recording_device == 'FPGA':
            ok_data = data[staring_point:,]  # all data is ok

        return ok_data

    ok_data = main()
    return ok_data


def tukey(v, size):  # Creates a ramp in the end of the generated chirp, to avoid side lobes
    if len(v) < 2*size:
        raise ValueError("Tukey window size too big for array")
    tuk = 0.5 * (1.0 - np.cos(np.pi * np.arange(size) / size))
    v[0:size] *= tuk   # ADD his line for curve at the beginning aswell
    v[-size:] *= tuk[::-1]

    return v


def generate_chirp(start_f, stop_f, T, fs):
    start_f = start_f  # Start frequency
    stop_f = stop_f  # Stop frequency
    T = T  # Time interval
    fs = fs  # sample rate assume 4*highest frecuency is enough
    N = fs*T

    t = np.linspace(0, T, int(T * fs), endpoint=False)
    t_space = 1/fs

    # normalisation factor used for inverse filter/matched filter
    # Below: sine and cos only represents the signals start phase.  try and use differen "chirp_signal"

    #  _______________________________Mark method_1_____________________________________
    # sine lin
    # chirp_signal = chirp(t, f0=start_f, t1=T, f1=stop_f, method='linear',phi=-90, vertex_zero=True )
    # sine log
    # chirp_signal = signal.chirp(t, f0=start_f, t1=T, f1=stop_f, method='logarithmic',phi=-90, vertex_zero=True )

    # cos lin
    # chirp_signal= chirp(t, f0=start_f, t1=T, f1=stop_f, method='linear', phi=0, vertex_zero=True)
    # cos log
    # chirp_signal = chirp(t, f0=start_f, t1=T, f1=stop_f, method='logarithmic',phi=-90, vertex_zero=True )
    # _________________________________________________________________________________

    # _______________________________linspace method_2__________________________________
    # Linear sine chirp
    # chirp_signal = np.sin(2 * np.pi * np.linspace(start_f, stop_f, N) * (t**2/2))   # according to farina
    # chirp_signal = np.sin(2 * np.pi * np.linspace(start_f, stop_f, N) * t**2)   # acording to random stackoverflow
    # logaritmic sine chirp
    # chirp_signal = np.sin(2 * np.pi * np.logspace(np.log10(start_f), np.log10(stop_f), N))
    # ________________________________________________________________________________

    # _________________________________Farina formula_________________________________
    # Linear   BAD IN CURRENT STATE
    # chirp_signal = np.sin(start_f*t + ((stop_f-start_f)/2)*((t**2)/2))

    # logarithmic  BAD IN CURRENT STATE
    # chirp_signal = np.sin(((np.pi*2*start_f*T)/(np.log(stop_f/start_f)))* (np.exp((t*np.log(stop_f/start_f))/T) -1 ))
    # Create the frequency vector

    # Modified Farina sweep   works ________________________________
    # L is used for the modified farina sweep
    L = (1/start_f)*((T*start_f)/(np.log(stop_f/start_f)))
    chirp_signal = np.sin(2*np.pi*start_f*L * (np.exp(t/L)-1))
    # _________________________________________________________________________________________________________

    # creates curve at the end of signal.
    TUKEY_SAMPLES = N // 16  # number of samples to create curve at the end of chirp
    # uncomment to ad tukey effect in the end.
    chirp_signal = tukey(chirp_signal, TUKEY_SAMPLES)

    # normalize the generated chirp to fit a target 24-bit range
    # scaling_factor = 8388607 / np.max(np.abs(chirp_signal))
    # chirp_signal_scaled = chirp_signal * scaling_factor
    # chirp_signal_scaled = np.round(chirp_signal * scaling_factor).astype(np.int32)
    # chirp_signal_scaled = chirp_signal_scaled.astype(np.int32)

    max_amplitude = np.max(np.abs(chirp_signal))
    scaling_factor = (2**23 - 1) / max_amplitude
    chirp_signal_scaled = np.round(
        chirp_signal * scaling_factor).astype(np.int32)
    # converts to int16
    # chirp_signal = np.int16((chirp_signal / chirp_signal.max()) * 32767)   # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.

    return chirp_signal_scaled


def create_sound_file(signal, fs, name):

    # converts to int16
    # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.
    signal = np.int16((signal / signal.max()) * 32767)

    write(name, fs, signal)


def calculate_IR(recording, T, N, fs, inverse_filter):

    time_output = np.linspace(0, T, N, endpoint=False)

    # plot time domain of recorded signal(sim)
    plt.subplot(4, 1, 1)
    plt.plot(time_output, recording)
    plt.xlabel("time (s)")
    plt.ylabel("amplitude")
    plt.title("Microphine recording (sim)")

    # plot magnitude spectrum of recorded signal(sim)
    output_fft = np.fft.fft(recording)
    t_space = 1/fs
    output_fft_freq = np.fft.fftfreq(len(recording), t_space)
    plt.subplot(4, 1, 2)
    plt.plot(output_fft_freq[0:N//2], np.abs(output_fft)[0:N//2])
    plt.xlabel("f (Hz)")
    plt.ylabel("amplitude")
    plt.title("Magnitude spectrum of recorded(sim)")

    # _____________________________#RECIEVE IMPULSE RESPONS METHOD 1. FARINA h(t)=y(t)*x(t)_________________________________________________________
    system_IR_Farina = np.convolve(recording, inverse_filter, mode='same')

    system_IR_Farina = system_IR_Farina/(np.max(np.abs(system_IR_Farina)))

    system_IR_fft_Farina = np.fft.fft(system_IR_Farina)
    freq = np.fft.fftfreq(len(system_IR_Farina), t_space)

    # plot time-domain IR
    plt.subplot(4, 1, 3)
    plt.plot(time_output, system_IR_Farina)
    plt.xlabel("time (s)")
    plt.ylabel("amplitude")
    plt.title("The IR of the system (recording * inverse-filter)  NORMALIZED")

    # Plot Amplitude of FFT
    plt.subplot(4, 1, 4)  # needs to be changed in order to plot
    plt.plot(freq[0:N//2], np.abs(system_IR_fft_Farina)[0:N//2])
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Amplitude')
    plt.title('The FR of the system (recording * inverse-filter)')
    # _____________________________________________________________________________________________________________________________________________

    plt.tight_layout()
    plt.show()

    return recording


def truncation(fft_IR):
    # Compute magnitude spectrum
    # mag_spec = np.abs(fft_IR)

    # Find the location of the largest peak in the impulse response
    max_index = np.argmax(np.abs(fft_IR))

# Extract a portion of the impulse response around the largest peak
    truncated_impulse_response = fft_IR[max_index-45:max_index+45]

    return truncated_impulse_response


def save_to_file(data, filename):
    with open(filename, "wb") as f:

        f.write(data)
    f.close
    sys.stdout.flush()


#################################################################################################
if __name__ == '__main__':
    # values used for generating the chirp
    start_f = 1  # Start frequency
    stop_f = 22000  # Stop frequency
    T = 2  # Time interval
    fs = 48828  # sample rate assume 4*highest frecuency is enough  44100 is normal for audio recording, maybe match our SR?
    N = fs*T

    # names for the audio files
    # filename_pure_chip = "chirp.wav"
    file_name_recording = "recording_sim.wav"
    filename_pure_chip = "farina_log_chirp.wav"
    # Generate chirp and its corresponding matched filter
    chirp_signal = generate_chirp(start_f, stop_f, T, fs)
    # create_sound_file(chirp_signal,fs,filename_pure_chip)

    # normalize to be able to create a audio file. same values is used here
    # chirp_signal = np.int16((chirp_signal / chirp_signal.max()) * 32767)   # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.

    print("Enter a filename for the recording: ")
    fileChooser = input()
    print("enter reference microphone microphone id")
    microphone = input()
    microphone = int(microphone)-1
    # print("press ENTER to start")
    input("press ENTER to start")
    record_time = T
    # collect_samples(fileChooser,record_time)    #if you wish do use a pre-recorde file, have this line as a comment

    # Recording contains data from alla microphones, reference_microphone cointains data from selected mic
    recording = print_analysis(fileChooser)

    # take out reference mic
    ref_mic = recording[:, int(microphone)]

    # Normalize chirp so it matches the recording
    # chirp_signal = chirp_signal.astype(np.float64)  # Cast to floating-point type
    # chirp_signal /= np.max(np.abs(chirp_signal))

    # Normalize the ref signal
    # ref_mic  = ref_mic.astype(np.float64)
    # ref_mic /= np.max(np.abs(ref_mic))

    # create the matched filter version
    t = np.linspace(0, T, int(T * fs), endpoint=False)
    R = np.log(stop_f/start_f)
    k = np.exp(t*R/T)
    # divide by k for constans FR for the matched filter
    matched_filter = chirp_signal[::-1]/k

    # print("lenght if matched_filter=",matched_filter.shape)

    fft_size = 2**12  # = 4096

    # get IR and FR for reference mic
    ref_mic_IR = np.convolve(ref_mic, matched_filter, mode='same')
    ref_mic_IR = truncation(ref_mic_IR)
    ref_mic_FR = np.fft.fft(ref_mic_IR, fft_size)

    # create an empty array to store the FFT of the scaling factors
    scaling_factor_array = np.zeros((64, fft_size), dtype=complex)
    for i in range(0, 64):

        mic = recording[:, i]  # .astype(np.float32)
        # Normalize the signal
        # mic  = mic.astype(np.float64)
        # mic /= np.max(np.abs(mic))

        # get IR and FR for other mic
        other_mic_IR = np.convolve(mic, matched_filter, mode='same')
        other_mic_IR = truncation(other_mic_IR)
        other_mic_FR = np.fft.fft(other_mic_IR, fft_size)

        # receive the frequency respons of the reference microphone

        scaling_factor = np.abs(ref_mic_FR/other_mic_FR)
        amp_scaling_factor = scaling_factor * \
            np.exp(1j * np.zeros_like(scaling_factor))
        # scaling_factor = scaling_factor.real + 0j
        # calculate scalingfactors for each freqeuncy bin

        scaling_factor_array[i, :] = amp_scaling_factor
    # save the scaling factors to a file
    np.save('hemma.npy', scaling_factor_array)
