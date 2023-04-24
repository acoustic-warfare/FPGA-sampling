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
   scaling_factor_fft = np.load('SF_full_len_fft_chirp_ref_28_ref.npy') 

   # access an individual scaling factor from the array
   #scaling_factor_i = scaling_factor_fft[:, microphone]
  
   fft_size=2**12   #= 4096
   
   #apply scaling factor
   #ref_mic_fft = ref_mic_fft*scaling_factor_fft[microphone,:]
   x = 0
   calibrated_mic_array = np.zeros((64, len(recording[:,0])), dtype=complex) 
   for i in range(0,64):
      #mic_fft= np.fft.fft(recording[:,i],fft_size)
      #if(i < 5):
      output = np.zeros_like(recording[:,i])
      for j in range(0, len(recording[:,i])// fft_size):   # iterate for as many chuncks is availble
        chunk = recording[:,i][j*fft_size:(j+1)*fft_size]
        
        chunk_fft = np.fft.fft(chunk,fft_size)
        chunk_fft = chunk_fft *scaling_factor_fft[i,:]
        chunk_ifft = np.fft.ifft(chunk_fft,fft_size)
        #print(chunk_ifft.shape)
        x = x+1
        
        output[j*fft_size:(j+1)*fft_size] = chunk_ifft.real
        
        

      #print(i)
      calibrated_mic_array[i,:] = output.real
   print(x)
   print(recording.shape)
   # what microphones to plot
   #plot_mics = [-33,26]
  # 17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,
  # 33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,
  # 49,50,51,52,54,55,57,58,59,60,61,62,63,64] 
  # 
   #plot_samples = math.floor(10000)   
                              
   #arr_plot_mics = np.array(plot_mics)-1   # convert plot_mics to numpy array with correct index
   #mic_legend = []                         # empty list that should hold legends for plot
   #plt.figure()
   #for i in range(len(arr_plot_mics)):
   #   plt.plot(calibrated_mic_array[int(arr_plot_mics[i]),:])
   #   mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
   #plt.xlim([0, plot_samples])
   #plt.xlabel('Samples')
   #plt.ylabel('Amplitude')
   #plt.suptitle('Selected microphones')
   #plt.legend(mic_legend)
   #plt.show()

   # Assume chirp is your chirp signal with N samples
   N = len(recording[:,0])
   time = np.arange(N) / 48828  # assuming sample_rate is known

   plt.subplot(3,1,1)
   plt.plot(recording[:,27][1000:1100],label="reference mic")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')
   plt.title('before calibration')


   mic_to_change = 2
   plt.subplot(3,1,1)
   #plt.plot(time, recording[:,35][2000:N])
   plt.plot(calibrated_mic_array[mic_to_change,:][1000:1100],label="calibrated mic")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')
   plt.title('before calibration')
   #plt.show()

   plt.subplot(3,1,2)
   plt.plot(recording[:,mic_to_change][1000:1100],label="uncalibrated mic")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')
   plt.title('before calibration')

   plt.subplot(3,1,2)
   #plt.plot(time, recording[:,35][2000:N])
   plt.plot(calibrated_mic_array[mic_to_change,:][1000:1100],label="calibrated mic")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')
   plt.title('before calibration')


   plt.subplot(3,1,3)
   plt.plot(recording[:,35][1000:1100],label="reference mic")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')
   plt.title('before calibration')

   plt.subplot(3,1,3)
   #plt.plot(time, recording[:,35][2000:N])
   plt.plot(recording[:,mic_to_change][1000:1100],label="uncalibrated mic")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')
   plt.title('before calibration')
   plt.show()
   

   # --- PLOT 1---
   plot_mics = [1,2,4,6,7,8,9,10,11,12,13,14,15,16,
   17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,
   33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,
   49,50,51,52,54,55,57,58,59,60,61,62,63,64]                   # what microphones to plot
   arr_plot_mics = np.array(plot_mics)-1   # convert plot_mics to numpy array with correct index
   mic_legend = []                         # empty list that should hold legends for plot
   plt.figure()
   for i in range(len(arr_plot_mics)):
      plt.plot(recording[:,int(arr_plot_mics[i])])
      mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
      plt.xlim([1000, 1060])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('Uncalibrated microphones')
      #plt.legend(mic_legend)
   

   # --- PLOT 2---
                                               # convert plot_mics to numpy array with correct index
   mic_legend = []                         # empty list that should hold legends for plot
   plt.figure()
   for i in range(len(arr_plot_mics)):
      plt.plot(calibrated_mic_array[int(arr_plot_mics[i]),:])
      mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
      plt.xlim([1000, 1060])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('calibrated microphones')
      #plt.legend(mic_legend)
   plt.show()
     


   