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
from scipy import signal 
from scipy.signal import butter, filtfilt,correlate,chirp,welch,periodogram


def print_analysis(fileChooser):



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
      
      # Load data from .BIN
      if recording_device == 'FPGA':
         data,fs,fileChooser = load_data_FPGA()
      #total_samples = len(data[:,0])          # Total number of samples
      #initial_data = data[0:initial_samples,] # takes out initial samples of signals 

      print("################# ANALYSE OF "+ fileChooser+" #################")
      print("\n")
      print('sample frequency: '+ str(int(fs)))

      staring_point = 0#40000                #default = 1000

      if recording_device == 'FPGA':
         ok_data = data[staring_point:,]  # all data is ok

      return ok_data
   
   ok_data = main()
   return ok_data

#################################################################################################
if __name__ == '__main__':

   #names for the audio files
   #filename_pure_chip = "chirp.wav"
 
   print("Enter a filename to analyze: ")
   fileChooser = input()
  
   
   #print("press ENTER to start")
   input("press ENTER to start")

   #collect_samples(fileChooser,record_time)    #if you wish do use a pre-recorde file, have this line as a comment

   recording= print_analysis(fileChooser)    #Recording contains data from alla microphones, reference_microphone cointains data from selected mic
   
  
   
   
   #scaling_factor_fft = np.fromfile(path,dtype=complex,count=-1,offset=0) #Read the whole file Scaling_factor size 4096
   

   #print(scaling_factor_fft.shape)
   # load the scaling factors from the saved file
   scaling_factor_fft = np.load('method2_short_d_log_high_3.npy') 

   # access an individual scaling factor from the array
   #scaling_factor_i = scaling_factor_fft[:, microphone]
  
   fft_size=145476   #= 4096
   
   #apply scaling factor
   #ref_mic_fft = ref_mic_fft*scaling_factor_fft[microphone,:]
  
    #apply scaling factor
   #ref_mic_fft = ref_mic_fft*scaling_factor_fft[microphone,:]
   
   calibrated_mic_array = np.zeros((64, len(scaling_factor_fft[0,:])), dtype=complex) 
   for i in range(0,64):
      #diff_len = len(scaling_factor_fft[i,:]) - len(recording[:,i])
      #padded_recording = np.pad(recording[:,i], (0, diff_len), mode='constant')
      
      chunk_fft = np.fft.fft(recording[:,i],fft_size)
      chunk_fft = chunk_fft * scaling_factor_fft[i,:]
      chunk_ifft = np.fft.ifft(chunk_fft,fft_size)
      calibrated_mic_array[i,:] = chunk_ifft
   
   
   print(recording.shape)
  

   # Assume chirp is your chirp signal with N samples
   N = len(recording[:,0])
   time = np.arange(N) / 48828  # assuming sample_rate is known
   mic_to_change = 12
   #plt.subplot(3,1,1)
   #plt.plot(recording[:,35],label="reference mic")
   #plt.xlabel('Time (s)')
   #plt.ylabel('Amplitude')
   #plt.legend(loc='upper right')
   #
#
#
   #
   #plt.subplot(3,1,1)
   ##plt.plot(time, recording[:,35][2000:N])
   #plt.plot(calibrated_mic_array[mic_to_change,:],label="calibrated mic")
   #plt.xlabel('Time (s)')
   #plt.ylabel('Amplitude')
   #plt.legend(loc='upper right')
   #plt.show()

   #plt.subplot(3,1,2)
   #plt.plot(recording[:,mic_to_change],label="uncalibrated mic")
   #plt.xlabel('Time (s)')
   #plt.ylabel('Amplitude')
   #plt.legend(loc='upper right')
   #plt.title('before calibration')
#
   #plt.subplot(3,1,2)
   ##plt.plot(time, recording[:,35][2000:N])
   #plt.plot(calibrated_mic_array[mic_to_change,:],label="calibrated mic")
   #plt.xlabel('Time (s)')
   #plt.ylabel('Amplitude')
   #plt.legend(loc='upper right')
   #plt.title('before calibration')


   plt.subplot(3,1,1)
   plt.plot(time,recording[:,35],label="reference MK36")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')

   plt.subplot(3,1,1)
   #plt.plot(time, recording[:,35][2000:N])
   plt.plot(time,recording[:,mic_to_change],label="uncalibrated MK13")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')

   plt.subplot(3,1,2)
   plt.plot(time,recording[:,35],label="reference MK36")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')
   

   # Assume chirp is your chirp signal with N samples
   N = len(calibrated_mic_array[0,:])
   time_cal = np.arange(N) / 48828  # assuming sample_rate is known
   
   plt.subplot(3,1,2)
   #plt.plot(time, recording[:,35][2000:N])
   plt.plot(time_cal,calibrated_mic_array[mic_to_change,:],label="calibrated MK13")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')
   plt.show()



   ## ____________________________________________________ ##
   ## Correct SPL value ## ___________________________________________________________________

   # ICS-52000 microphone Full-scale sensitivity (-26 dBFS/Pa)
   sensitivity = -26.0

   # Define the reference voltage and sound pressure level
   Vref = 1.0 # volt
   SPLref = 94.0 # dB SPL

   for i in range(0,64):
      waveform_uncal = recording[:,i] / (2 ** 24 -1)
      waveform_cal = calibrated_mic_array[i,:] / (2 ** 24 -1)

      # Convert the waveform to RMS voltage
      Vrms_uncal = np.sqrt(np.mean(waveform_uncal ** 2))
      Vrms_cal = np.sqrt(np.mean(np.abs(waveform_cal) ** 2))

      # Calculate the SPL value using the formula
      SPL_uncal = 20 * np.log10(Vrms_uncal / 0.0501187234) + SPLref
      SPL_cal = 20 * np.log10(Vrms_cal / 0.0501187234) + SPLref

      # Print the calculated SPL value
      print('SPL Uncalibrated mic'+str(i+1)+': {:.2f} dB.....SPL calibrated: {:.2f} dB'.format(SPL_uncal,SPL_cal))


   

   # --- PLOT 1---
   plot_mics = [1,2,4,6,7,8,9,10,11,12,13,14,15,16,
   17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,
   33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,
   49,50,51,52,54,55,57,58,59,60,61,62,63,64]                   # what microphones to plot
   arr_plot_mics = np.array(plot_mics)-1   # convert plot_mics to numpy array with correct index
   mic_legend = []                         # empty list that should hold legends for plot

   # Create a figure with two subplots

   plt.subplot(1,1,1)
   for i in range(len(arr_plot_mics)):
      plt.plot(recording[:,int(arr_plot_mics[i])],color="red")
      mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
      plt.xlim([10000, 10100])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('Uncalibrated microphones')
      #plt.legend(mic_legend)
   

   # --- PLOT 2---
                                               # convert plot_mics to numpy array with correct index
   mic_legend = []                         # empty list that should hold legends for plot
   plt.subplot(1,1,1)
   for i in range(len(arr_plot_mics)):
      plt.plot(calibrated_mic_array[int(arr_plot_mics[i]),:],color="blue")
      mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
      plt.xlim([10000, 10100])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('calibrated microphones')
      #plt.legend(mic_legend)
   plt.show()
     


   