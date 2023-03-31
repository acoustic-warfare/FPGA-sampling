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
#import config
import os
from scipy.io.wavfile import write
import threading
import multiprocessing
# This scripts listen on an port and collects array samples and then plots the graphs direcly!
# Enter a filename and how long you want to record.
# Pick a horizontal line or a vertical line.
# the plotted graphs will show
# to make a new recording simply close all the graphs and a new session is started. 



def collect_samples(filename,recordTime):
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
         ("mic_1", c_int32),
         ("mic_2", c_int32),
         ("mic_3", c_int32),
         ("mic_4", c_int32),
         ("mic_5", c_int32),
         ("mic_6", c_int32),
         ("mic_7", c_int32),
         ("mic_8", c_int32),
         ("mic_9", c_int32),
         ("mic_10", c_int32),
         ("mic_11", c_int32),
         ("mic_12", c_int32),
         ("mic_13", c_int32),
         ("mic_14", c_int32),
         ("mic_15", c_int32),
         ("mic_16", c_int32),
         ("mic_17", c_int32),
         ("mic_18", c_int32),
         ("mic_19", c_int32),
         ("mic_20", c_int32),
         ("mic_21", c_int32),
         ("mic_22", c_int32),
         ("mic_23", c_int32),
         ("mic_24", c_int32),
         ("mic_25", c_int32),
         ("mic_26", c_int32),
         ("mic_27", c_int32),
         ("mic_28", c_int32),
         ("mic_29", c_int32),
         ("mic_30", c_int32),
         ("mic_31", c_int32),
         ("mic_32", c_int32),
         ("mic_33", c_int32),
         ("mic_34", c_int32),
         ("mic_35", c_int32),
         ("mic_36", c_int32),
         ("mic_37", c_int32),
         ("mic_38", c_int32),
         ("mic_39", c_int32),
         ("mic_40", c_int32),
         ("mic_41", c_int32),
         ("mic_42", c_int32),
         ("mic_43", c_int32),
         ("mic_44", c_int32),
         ("mic_45", c_int32),
         ("mic_46", c_int32),
         ("mic_47", c_int32),
         ("mic_48", c_int32),
         ("mic_49", c_int32),
         ("mic_50", c_int32),
         ("mic_51", c_int32),
         ("mic_52", c_int32),
         ("mic_53", c_int32),
         ("mic_54", c_int32),
         ("mic_55", c_int32),
         ("mic_56", c_int32),
         ("mic_57", c_int32),
         ("mic_58", c_int32),
         ("mic_59", c_int32),
         ("mic_60", c_int32),
         ("mic_61", c_int32),
         ("mic_62", c_int32),
         ("mic_63", c_int32),
         ("mic_64", c_int32),          
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

      #for count in itertools.count():
      while time.time()<t_end:
         data = sock.recv(sizeof(Data))
         
         d = Data.from_buffer_copy(data)
         f.write(d)
   f.close
   sys.stdout.flush()

def print_analysis(fileChooser,microphone):


   def load_data_FPGA():
      #   FUNCTION TO LOAD DATA FROM .BIN FILE INTO NUMPY ARRAY 
      #   (RECORDED BY FPGA)

      ROOT = os.getcwd()
      path = Path(ROOT + "/"+fileChooser)
   
      data = np.fromfile(path,dtype=c_int32,count=-1,offset=0) #Read the whole file
      data2D = data.reshape(-1,68)  # reshapes into a Numpy array which is N*68 in dimensions
      

      
     
      ## Data2D holds all information from the file.
      ## Data2D[n][0] = array id
      ## Data2D[n][1] = protocol version
      ## Data2D[n][2] = frequency
      ## Data2D[n][3] = array sample counter
      ## Data2D[n][4] to  Data2D[n][67] = is microphone 1 to 64

      

      micData = data2D[:,4:] #An array with only mic data. i.e removes (Array id, protocol version, freq and counter)
      f_sampling = np.fromfile(path,dtype=c_int32,count=1,offset=8) # get sampling frequency from the file
      #f_sampling = 10000
      return micData, int(f_sampling),fileChooser

   def main():
      recording_device = 'FPGA' # choose between 'FPGA' and 'BB' (BeagelBone) 
      filename = 'new_sample_data_new'

      initial_samples = 10000                 # initial samples, at startup phase of Beaglebone recording

      # Load data from .BIN
      if recording_device == 'FPGA':
         data,fs,fileChooser = load_data_FPGA()
      #total_samples = len(data[:,0])          # Total number of samples
      #initial_data = data[0:initial_samples,] # takes out initial samples of signals 

      new_lab_data = 0
      for i in range(0,64):
         new_lab_data = np.add(new_lab_data,data[:,i])

      new_lab_data = new_lab_data/64
      print("################# ANALYSE OF "+ fileChooser+" #################")
      print("\n")
      print("total nr samples in file: "+str(len(new_lab_data)))
      print('sample frequency: '+ str(int(fs)))

      staring_point = 1000                #default = 1000

      if recording_device == 'FPGA':
         ok_data = data[staring_point:,]  # all data is ok

      #samples = len(ok_data[:,0])         #total number of samples per microphone

      microphones=[1,2,4,6,7,8,9,10,11,12,13,14,15,16,
                   17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,
                   33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,
                   49,50,51,52,54,55,57,58,59,60,61,62,63,64]  
      microphones = np.array(microphones)-1
      # This takes out recordings of multiple microphones, the varieble "microphones" represent the id of mics to record with.                     
      #arr_plot_mics = np.array(microphones)-1   # convert plot_mics to numpy array with correct index
      #for i in range(len(arr_plot_mics)):
      #  multiple_microphones= (ok_data[:,int(arr_plot_mics[i])])
      
      recording=ok_data[:,microphones]  #change this to "microphones" to get all mics
      reference_microphone = ok_data[:,microphones] 
      return recording
   
   main()

def tukey (v, size):  ## Creates a ramp in the end of the generated chirp, to avoid side lobes 
    if len(v) < 2*size:
        raise ValueError ("Tukey window size too big for array")
    tuk = 0.5 * (1.0 - np.cos (np.pi * np.arange(size) / size))
    #v[0:size] *= tuk   # ADD his line for curve at the beginning aswell
    v[-size:] *= tuk[::-1]
    
    return v

def generate_chirp(start_f,stop_f,T,fs):
   start_f=start_f         #Start frequency
   stop_f=stop_f      #Stop frequency   
   T=T               #Time interval
   fs=fs          #sample rate assume 4*highest frecuency is enough
   N = fs*T

   t = np.linspace(0, T, int(T * fs), endpoint=False)
   t_space = 1/fs

   

   #normalisation factor used for inverse filter/matched filter
    #Below: sine and cos only represents the signals start phase.  try and use differen "chirp_signal"

    
   #  _______________________________Mark method_1_____________________________________ 
        # sine lin
   #chirp_signal = chirp(t, f0=start_f, t1=T, f1=stop_f, method='linear',phi=-90, vertex_zero=True ) 
        # sine log       
   #chirp_signal = chirp(t, f0=start_f, t1=T, f1=stop_f, method='logarithmic',phi=-90, vertex_zero=True )   
        
        # cos lin
   #chirp_signal= chirp(t, f0=start_f, t1=T, f1=stop_f, method='linear', phi=0, vertex_zero=True) 
        # cos log         
   #chirp_signal = chirp(t, f0=start_f, t1=T, f1=stop_f, method='logarithmic',phi=-90, vertex_zero=True )  
   #_________________________________________________________________________________
   
   
   
   #_______________________________linspace method_2__________________________________    
        #Linear sine chirp 
   #chirp_signal = np.sin(2 * np.pi * np.linspace(start_f, stop_f, N) * (t**2/2))   # according to farina
   #chirp_signal = np.sin(2 * np.pi * np.linspace(start_f, stop_f, N) * t**2)   # acording to random stackoverflow                                                                      
        #logaritmic sine chirp
   #chirp_signal = np.sin(2 * np.pi * np.logspace(np.log10(start_f), np.log10(stop_f), N))
   #________________________________________________________________________________
   

   #_________________________________Farina formula_________________________________ 
         #Linear   BAD IN CURRENT STATE
   #chirp_signal = np.sin(start_f*t + ((stop_f-start_f)/2)*((t**2)/2))

         #logarithmic  BAD IN CURRENT STATE
   #chirp_signal = np.sin(((np.pi*2*start_f*T)/(np.log(stop_f/start_f)))* (np.exp((t*np.log(stop_f/start_f))/T) -1 ))
   # Create the frequency vector
   
         #Modified Farina sweep   works ________________________________
   #L is used for the modified farina sweep
   L= (1/start_f)*((T*start_f)/(np.log(stop_f/start_f)))
   chirp_signal = np.sin(2*np.pi*start_f*L *(np.exp(t/L)-1))
   #_________________________________________________________________________________________________________
   
   
   
   
   #creates curve at the end of signal.
   TUKEY_SAMPLES = N //16  ## number of samples to create curve at the end of chirp
   #chirp_signal = tukey(chirp_signal,TUKEY_SAMPLES)                                   #uncomment to ad tukey effect in the end.

   
   #converts to int16
   #chirp_signal = np.int16((chirp_signal / chirp_signal.max()) * 32767)   # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.
   
   #create the inverse filter version
   R = np.log(stop_f/start_f)
   k = np.exp(t*R/T)
   inverse_filter =  chirp_signal[::-1]/k

   chirp_signal_dirac=np.convolve(chirp_signal,inverse_filter,mode='same')  

   chirp_signal_dirac = chirp_signal_dirac/np.max(np.abs(chirp_signal_dirac))  # Normalized to have the same amplitude as the generated chirp
   return chirp_signal,inverse_filter

def create_sound_file(signal,fs,name):

   #converts to int16
   signal = np.int16((signal / signal.max()) * 32767)   # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.

   write(name,fs , signal)

def calculate_IR(recording,T,N,fs,inverse_filter):
   
   
   time_output = np.linspace(0,T,N,endpoint=False)

   #plot time domain of recorded signal(sim)
   plt.subplot(4,1,1)
   plt.plot(time_output,recording)
   plt.xlabel("time (s)")
   plt.ylabel("amplitude")
   plt.title("Microphine recording (sim)")

   #plot magnitude spectrum of recorded signal(sim)
   output_fft=np.fft.fft(recording)
   t_space = 1/fs
   output_fft_freq = np.fft.fftfreq(len(recording), t_space)
   plt.subplot(4,1,2)
   plt.plot(output_fft_freq[0:N//2],np.abs(output_fft)[0:N//2])
   plt.xlabel("f (Hz)")
   plt.ylabel("amplitude")
   plt.title("Magnitude spectrum of recorded(sim)")


   #_____________________________#RECIEVE IMPULSE RESPONS METHOD 1. FARINA h(t)=y(t)*x(t)_________________________________________________________
   system_IR_Farina= np.convolve(recording,inverse_filter,mode='same')

   system_IR_Farina = system_IR_Farina/(np.max(np.abs(system_IR_Farina)))

   system_IR_fft_Farina = np.fft.fft(system_IR_Farina)
   freq = np.fft.fftfreq(len(system_IR_Farina), t_space)

   # plot time-domain IR
   plt.subplot(4,1,3)
   plt.plot(time_output,system_IR_Farina)
   plt.xlabel("time (s)")
   plt.ylabel("amplitude")
   plt.title("The IR of the system (recording * inverse-filter)  NORMALIZED"  )


   ## Plot Amplitude of FFT
   plt.subplot(4,1,4)                                                                  #needs to be changed in order to plot
   plt.plot(freq[0:N//2], np.abs(system_IR_fft_Farina)[0:N//2])
   plt.xlabel('Frequency (Hz)')
   plt.ylabel('Amplitude')
   plt.title('The FR of the system (recording * inverse-filter)')
   #_____________________________________________________________________________________________________________________________________________
   
   
   #____________________________#RECIEVE IMPULSE RESPONS METHOD 2. division in frequency domain______________________________________________
   #output_fft = np.fft.fft(output)
   #chirp_fft = np.fft.fft(chirp_signal)
##
   ##do the division explained in work of angelo Farina 2000. __________________________________________________ #Not very useful atm
   #division_IR_fft = output_fft / chirp_fft
##
   #division_IR_time=np.fft.ifft(division_IR_fft)
   #freq = np.fft.fftfreq(len(output), t_space)
   #
   ## plot time-domain IR
   #plt.subplot(4,1,3)
   #plt.plot(time_output,division_IR_time)
   #plt.xlabel("time (s)")
   #plt.ylabel("amplitude")
   #plt.title("The IR if the system (recording * inverse-filter)")
   #
   ##t_space= 1/fs
##
   ###Convert to frecuency domain
   ##freq = np.fft.fftfreq(len(chirp_signal), t_space)
   ##
   ### Plot Amplitude of FFT
   #plt.subplot(4,1,4)                                                                  #needs to be changed in order to plot
   #plt.plot(freq[0:N//2], np.abs(division_IR_fft)[0:N//2])
   #plt.xlabel('Frequency (Hz)')
   #plt.ylabel('Amplitude')
   #plt.title('Frequency spectrum of IR')
   ##__________________________________________________________________________________________________________
   

   plt.tight_layout()
   plt.show()

   return recording


#################################################################################################
if __name__ == '__main__':
   ### values used for generating the chirp
   start_f=1         #Start frequency
   stop_f=22000      #Stop frequency   
   T=2               #Time interval
   fs=44100          #sample rate assume 4*highest frecuency is enough  44100 is normal for audio recording, maybe match our SR?
   N = fs*T

   #names for the audio files
   filename_pure_chip = "chirp.wav"
   file_name_recording = "recording_sim.wav"

   chirp_signal,inverse_filter = generate_chirp(start_f,stop_f,T,fs)   #Generate chirp and its corresponding inverse filter
   create_sound_file(chirp_signal,fs,filename_pure_chip)

   #normalize to be able to create a audio file. same values is used here
   chirp_signal = np.int16((chirp_signal / chirp_signal.max()) * 32767)   # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.

   print("Enter a filename for the recording: ")
   fileChooser = input()
   print("enter reference microphone microphone id")
   microphone=input()

   #print("press ENTER to start")
   input("press ENTER to start")
   collect_samples(fileChooser,T)

   recording = print_analysis(fileChooser,microphone)    #enter microphone to record
   #create_sound_file(recording,fs,file_name_recording)

   calculate_IR(recording,T,N,fs,inverse_filter)





   #___________________ plotta spl db____________________________
   # Apply the FFT to the signal
   #fft = np.fft.fft(signal)
   #
   ## Compute the magnitude spectrum in decibels (dB)
   #magnitude = np.abs(fft)
   #magnitude_db = 20 * np.log10(magnitude)
   #
   ## Compute the frequency axis
   #freq_axis = np.fft.fftfreq(len(signal), d=1/sample_rate)
   #
   ## Plot the magnitude spectrum
   #plt.plot(freq_axis, magnitude_db)

   # Generate some example data
   #t = np.linspace(0, 10, 1000)
   #f = np.linspace(0, 1000, 100)
   #power = np.random.rand(len(t), len(f))
   #
   ## Create the plot
   #fig, ax = plt.subplots()
   #im = ax.imshow(power, cmap='hot', aspect='auto', extent=[t[0], t[-1], f[0], f[-1]])
   #ax.set_xlabel('Time')
   #ax.set_ylabel('Frequency')
   #ax.set_title('Power Heatmap')
   #
   ## Add a colorbar
   #cbar = ax.figure.colorbar(im, ax=ax)
   #cbar.ax.set_ylabel('Power', rotation=-90, va='bottom')
   #
   #plt.show()