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
   
  
   #mic sensitivity 10^(-26/20)=   0.0501187234 V/Pa
   
   #scaling_factor_fft = np.fromfile(path,dtype=complex,count=-1,offset=0) #Read the whole file Scaling_factor size 4096
   

   #print(scaling_factor_fft.shape)
   # load the scaling factors from the saved file
   scaling_factor_fft = np.load('kalibrera_880hz_6m_phase.npy') 

   # tukey_log_3_sec.npy
   # pcba1_log_3.npy
   # 24_bit_chirp_close.npy

   #24_bit_chirp_close_5.npy    denna är bra för första slingan!!!!!!!!!!!  big_speaker
   #tukey_log_3_sec_5.npy       flat_speaker

   #hemma.npy
   #'method2_tukey_bit.npy'


   #'svante_24_bit_5_ref.npy'
   #'kalibrera_4000hz.npy'
   #'kalibrera_880hz_6m_phase.npy'
  
   fft_size=2**18   #= 4096
   
   #apply scaling factor
  
   
   calibrated_mic_array = np.zeros((64, fft_size), dtype=complex) 
   for i in range(0,64):
      mic_fft= np.fft.fft(recording[:,i],fft_size)
      #if(i < 5):
      output = np.zeros_like(recording[:,i])
      
        
      
      mic_calibrated_fft = mic_fft *scaling_factor_fft[i,:]
      mic_calibrated = np.fft.ifft(mic_calibrated_fft,fft_size)
      #print(chunk_ifft.shape

      #print(i)
      calibrated_mic_array[i,:] = mic_calibrated.real
 
  

   # Assume chirp is your chirp signal with N samples
   N = fft_size
   time = np.arange(N) / 48828  # assuming sample_rate is known
   mic_to_change = 36
   reference = 4
   #plt.subplot(3,1,1)
   #plt.plot(recording[:,35],label="reference mic")
   #plt.xlabel('Time (s)')
   #plt.ylabel('Amplitude')
   #plt.legend(loc='upper right')
   #
#
#



   plt.subplot(3,1,1)
   plt.plot(recording[:,reference],label="reference MK")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')

   plt.subplot(3,1,1)
   #plt.plot(time, recording[:,35][2000:N])
   plt.plot(recording[:,mic_to_change],label="uncalibrated MK4")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')

   plt.subplot(3,1,2)
   plt.plot(recording[:,reference],label="reference MK")
   plt.xlabel('Time (s)')
   plt.ylabel('Amplitude')
   plt.legend(loc='upper right')
   


   
   plt.subplot(3,1,2)
   #plt.plot(time, recording[:,35][2000:N])
   plt.plot(calibrated_mic_array[mic_to_change,:],label="calibrated MK4")
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
      waveform_uncal = recording[:,i][0:len(recording[:,0])] / (2 ** 24 -1)
      waveform_cal = calibrated_mic_array[i,:][0:len(recording[:,0])] / (2 ** 24 -1)

      # Convert the waveform to RMS voltage
      Vrms_uncal = np.sqrt(np.mean(waveform_uncal ** 2))
      Vrms_cal = np.sqrt(np.mean(np.abs(waveform_cal) ** 2))

      # Calculate the SPL value using the formula
      SPL_uncal = 20 * np.log10(Vrms_uncal / 0.0501187234) + SPLref
      SPL_cal = 20 * np.log10(Vrms_cal / 0.0501187234) + SPLref

      # Print the calculated SPL value
      print('SPL Uncalibrated mic'+str(i+1)+': {:.2f} dB.....SPL calibrated: {:.2f} dB'.format(SPL_uncal,SPL_cal))   



   #Visar en slinga uppdelat på en rad
   # --- PLOT 1---
   plot_mics = [1,2,3,4,5,6,7,8]                   # what microphones to plot
   arr_plot_mics = np.array(plot_mics)-1   # convert plot_mics to numpy array with correct index
   mic_legend = []                         # empty list that should hold legends for plot

   # Create a figure with two subplots

   #plt.subplot(2,1,1)
   #for i in range(len(arr_plot_mics)):
   #   plt.plot(recording[:,int(arr_plot_mics[i])],color="blue",label="row 2")
   #   mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
   #   plt.xlim([10000, 10100])
   #   plt.xlabel('Samples')
   #   plt.ylabel('Amplitude')
   #   plt.suptitle('mic-1 to 8')
   #plt.legend(loc='upper right')
   #
#
   ## --- PLOT 2---
   #                                            # convert plot_mics to numpy array with correct index
   #plot_mics = [9,10,11,12,13,14,15,16] 
   #arr_plot_mics = np.array(plot_mics)-1   # convert plot_mics to numpy array with correct index
   #mic_legend = []                         # empty list that should hold legends for plot
   #plt.subplot(2,1,1)
   #for i in range(len(arr_plot_mics)):
   #   plt.plot(recording[:,int(arr_plot_mics[i])],color="orange",label='row 1')
   #   mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
   #   plt.xlim([10000, 10100])
   #   plt.xlabel('Samples')
   #   plt.ylabel('Amplitude')
   #   plt.suptitle('mic-9 to 16')
   #plt.legend(loc='upper right')
   
   plt.show()
   #[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16] 
   #48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64
   #Visar alla för och efter
   # --- PLOT 1---
   plot_mics = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]                  # what microphones to plot
   arr_plot_mics = np.array(plot_mics)-1   # convert plot_mics to numpy array with correct index
   mic_legend = []                         # empty list that should hold legends for plot

   # Create a figure with two subplots

   plt.subplot(2,1,1)
   for i in range(len(arr_plot_mics)):
      plt.plot(recording[:,int(arr_plot_mics[i])],color="blue",label="uncalibrated")
      mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
      plt.xlim([10000, 10100])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('Uncalibrated microphones')
   #plt.legend(loc='upper right')
   

   # --- PLOT 2---
                                               # convert plot_mics to numpy array with correct index
   mic_legend = []                         # empty list that should hold legends for plot
   plt.subplot(2,1,2)
   for i in range(len(arr_plot_mics)):
      plt.plot(calibrated_mic_array[int(arr_plot_mics[i]),:],color="orange",label='calibrated')
      mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
      plt.xlim([10000, 10100])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('calibrated microphones')
   #plt.legend(loc='upper right')
   
   plt.show()






   #visar enskilda slingor
   

   # --- PLOT 1---
   plot_mics1 = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
   plot_mics2 = [17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]
   plot_mics3 = [33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48]
   plot_mics4 = [49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64]  
   
  
                    # what microphones to plot
   arr_plot_mics1 = np.array(plot_mics1)-1   # convert plot_mics to numpy array with correct index
   arr_plot_mics2 = np.array(plot_mics2)-1   # convert plot_mics to numpy array with correct index
   arr_plot_mics3 = np.array(plot_mics3)-1   # convert plot_mics to numpy array with correct index
   arr_plot_mics4 = np.array(plot_mics4)-1   # convert plot_mics to numpy array with correct index
   mic_legend = []                         # empty list that should hold legends for plot

   # Create a figure with two subplots

   for i in range(len(arr_plot_mics1)):
      plt.subplot(4,1,1)
      plt.plot(recording[:,int(arr_plot_mics1[i])])
     # mic_legend = np.append(mic_legend,str(arr_plot_mics1[i]+1))
      plt.xlim([10000, 10100])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('before calibration')
      plt.legend(mic_legend)
   #plt.show()

   # --- PLOT 2---
                                               # convert plot_mics to numpy array with correct index
   mic_legend = []                         # empty list that should hold legends for plot
   
   for i in range(len(arr_plot_mics2)):
      plt.subplot(4,1,2)
      plt.plot(recording[:,int(arr_plot_mics2[i])])
     # mic_legend = np.append(mic_legend,str(arr_plot_mics2[i]+1))
      plt.xlim([10000, 10100])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('before calibration')
      plt.legend(mic_legend)
   #plt.show()

   for i in range(len(arr_plot_mics3)):
     plt.subplot(4,1,3)
     plt.plot(recording[:,int(arr_plot_mics3[i])])
    # mic_legend = np.append(mic_legend,str(arr_plot_mics3[i]+1))
     plt.xlim([10000, 10100])
     plt.xlabel('Samples')
     plt.ylabel('Amplitude')
     plt.suptitle('before calibration')
     plt.legend(mic_legend)


   for i in range(len(arr_plot_mics4)):
     plt.subplot(4,1,4)
     plt.plot(recording[:,int(arr_plot_mics4[i])])
    # mic_legend = np.append(mic_legend,str(arr_plot_mics4[i]+1))
     plt.xlim([10000, 10100])
     plt.xlabel('Samples')
     plt.ylabel('Amplitude')
     plt.suptitle('before calibration')
     plt.legend(mic_legend)
   plt.tight_layout()
   plt.show()
   

#____________________________________________________________________________________________

   
   for i in range(len(arr_plot_mics1)):
      plt.subplot(4,1,1)
      plt.plot(calibrated_mic_array[int(arr_plot_mics1[i]),:])
     # mic_legend = np.append(mic_legend,str(arr_plot_mics1[i]+1))
      plt.xlim([10000, 10100])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('Uncalibrated microphones')
      plt.legend(mic_legend)
   #plt.show()

   # --- PLOT 2---
                                               # convert plot_mics to numpy array with correct index
   mic_legend = []                         # empty list that should hold legends for plot
   
   for i in range(len(arr_plot_mics2)):
      plt.subplot(4,1,2)
      plt.plot(calibrated_mic_array[int(arr_plot_mics2[i]),:])
     # mic_legend = np.append(mic_legend,str(arr_plot_mics2[i]+1))
      plt.xlim([10000, 10100])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('calibrated microphones')
      plt.legend(mic_legend)
   #plt.show()

   for i in range(len(arr_plot_mics3)):
     plt.subplot(4,1,3)
     plt.plot(calibrated_mic_array[int(arr_plot_mics3[i]),:])
    # mic_legend = np.append(mic_legend,str(arr_plot_mics3[i]+1))
     plt.xlim([10000, 10100])
     plt.xlabel('Samples')
     plt.ylabel('Amplitude')
     plt.suptitle('calibrated microphones')
     plt.legend(mic_legend)


   for i in range(len(arr_plot_mics4)):
     plt.subplot(4,1,4)
     plt.plot(calibrated_mic_array[int(arr_plot_mics4[i]),:])
    # mic_legend = np.append(mic_legend,str(arr_plot_mics4[i]+1))
     plt.xlim([10000, 10100])
     plt.xlabel('Samples')
     plt.ylabel('Amplitude')
     plt.suptitle('calibrated microphones')
     plt.legend(mic_legend)
   plt.tight_layout()
   plt.show()


   