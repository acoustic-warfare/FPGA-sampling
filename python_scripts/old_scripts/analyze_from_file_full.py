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


def print_analysis(fileChooser,microphones,source_audio):


   def load_data_FPGA(filename):
      #   FUNCTION TO LOAD DATA FROM .TXT FILE INTO NUMPY ARRAY 
      #   (RECORDED BY FPGA)

      ROOT = os.getcwd()
      path = Path(ROOT + "/"+fileChooser)
   
      data = np.fromfile(path,dtype=c_int32,count=-1,offset=0) #Read the whole file
      data2D = data.reshape(-1,258)  # reshapes into a Numpy array which is N*68 in dimensions
      micData = data2D[:,2:]    # removes headerinformation
      #f_sampling = np.fromfile(path,dtype=c_int32,count=1,offset=8) # get sampling frequency from the file
      f_sampling = 48828
      return micData, int(f_sampling),fileChooser

   def main():
      recording_device = 'FPGA' # choose between 'FPGA' and 'BB' (BeagelBone) 
      filename = 'ljud'

      initial_samples = 10000                 # initial samples, at startup phase of Beaglebone recording

      # Choose the mic signals that should be set to zero
      #mics_to_delete = [8, 38]
      #arr_mics_to_delete = np.array(mics_to_delete, dtype = int)-1 # converts mic_to_delete to numpy array with correct index

      # Plot options
      plot_period = 1     # periods to plot
      f0 = int(source_audio)           # frequency of recorded sinus signal
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
      print("################# ANALYSE OF "+ fileChooser+" #################")
      print("\n")
      print("total nr samples in file: "+str(len(new_lab_data)))
      

      lab_test_mic = 1
      initial_lab_test_sample = 10000
      lab_test_samples = 5000
      lab_test_data = data[initial_lab_test_sample:initial_lab_test_sample+lab_test_samples,lab_test_mic]
      lab_test_power = np.sum(np.abs(lab_test_data)* np.abs(lab_test_data))/lab_test_samples /pow(2,23)
      print("power: "+str(lab_test_power))

      staring_point = 1000    #default = 1000

      if recording_device == 'FPGA':
         ok_data = data[staring_point:,] # all data is ok


      plot_samples = math.floor(plot_period*(fs/f0)*2)                     # number of samples to plot, to use for axis scaling
      max_value_ok = np.max(np.max(ok_data[0:4000,],axis=0)) # maximum value of data, to use for axis scaling in plots

      print('sample frequency: '+ str(int(fs)))

      # --- PLOT 1---
      #   of all individual signals in subplots, two periods
      fig, axs = plt.subplots(4,16)
      fig.suptitle("Individual signals 1-64", fontsize=16)
      start_val = 4000
      
      for j in range(4):
         for i in range(16):
               axs[j,i].plot(ok_data[start_val:start_val+plot_samples,i+j*16])
               axs[j,i].set_title(str(i+j*16+1), fontsize=8)
               axs[j,i].axis('off')
               #if normalized:
               #   axs[j,i].set_ylim(-max_value_ok*1.1, max_value_ok*1.1)

      fig, axs = plt.subplots(4,16)
      fig.suptitle("Individual signals 65-128", fontsize=16)

      for j in range(4):
         for i in range(16):
               axs[j,i].plot(ok_data[start_val:start_val+plot_samples,i+j*16+64])
               axs[j,i].set_title(str(i+j*16+1+64), fontsize=8)
               axs[j,i].axis('off')
               #if normalized:
               #   axs[j,i].set_ylim(-max_value_ok*1.1, max_value_ok*1.1)

      fig, axs = plt.subplots(4,16)
      fig.suptitle("Individual signals 129-192", fontsize=16)
      start_val = 4000

      for j in range(4):
         for i in range(16):
               axs[j,i].plot(ok_data[start_val:start_val+plot_samples,i+j*16+128])
               axs[j,i].set_title(str(i+j*16+1+128), fontsize=8)
               axs[j,i].axis('off')
               #if normalized:
               #   axs[j,i].set_ylim(-max_value_ok*1.1, max_value_ok*1.1)

      fig, axs = plt.subplots(4,16)
      fig.suptitle("Individual signals 193-256", fontsize=16)
      start_val = 4000

      for j in range(4):
         for i in range(16):
               axs[j,i].plot(ok_data[start_val:start_val+plot_samples,i+j*16+192])
               axs[j,i].set_title(str(i+j*16+1+192), fontsize=8)
               axs[j,i].axis('off')
               #if normalized:
               #   axs[j,i].set_ylim(-max_value_ok*1.1, max_value_ok*1.1)

      # Set microphone signals of bad mics to zero
      #clean_data = delete_mic_data(ok_data, arr_mics_to_delete)
      #clean_initial_data = delete_mic_data(initial_data, arr_mics_to_delete)

      # --- PLOT 2---
      #   plot of all microphones, after bad signals have been set to 0
      #plt.figure()
      #plt.plot(ok_data)
      #plt.xlim([0, plot_samples])
      #plt.xlabel('Samples')
      #plt.ylabel('Amplitude')
      #plt.suptitle('All microphones')
      #if normalized:
      #   plt.ylim([-max_value_ok*1.1, max_value_ok*1.1])
      #
      
   #Copy these values and but in "plot_mices"

  #[1,2,4,6,7,8,9,10,11,12,13,14,15,16,
  # 17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,
  # 33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,
  # 49,50,51,52,54,55,57,58,59,60,61,62,63,64]  
            
            # --- PLOT 3---
      #   of selected microphones

      #plot_mics = microphones                    # what microphones to plot
      #arr_plot_mics = np.array(plot_mics)-1   # convert plot_mics to numpy array with correct index
      #mic_legend = []                         # empty list that should hold legends for plot
      #plt.figure()
      #for i in range(len(arr_plot_mics)):
      #   plt.plot(ok_data[:,int(arr_plot_mics[i])], '-*')
      #   mic_legend = np.append(mic_legend,str(arr_plot_mics[i]+1))
      #plt.xlim([0, plot_samples])
      #plt.xlabel('Samples')
      #plt.ylabel('Amplitude')
      #plt.suptitle('Selected microphones')
      #plt.legend(mic_legend)
      #if normalized:
      #   plt.ylim([-max_value_ok*1.1, max_value_ok*1.1])
#
      ## --- PLOT  4---
      #plt.figure()
      #plt.plot(initial_data[:,3])
      #plt.plot(new_lab_data)
      #plt.xlim([0, initial_samples])
      #plt.xlabel('Samples')
      #plt.ylabel('Amplitude')
      #plt.suptitle('Initial values')
      #
      ## --- PLOT 5---
      ##   of FFT of several signals
      #mics_FFT = microphones
      #samples = len(ok_data[:,0])
      #t_stop = samples/fs
      #t = np.linspace(0,t_stop,samples)
      #arr_mics_FFT = np.array(mics_FFT,dtype=int)-1
      #FFT_mic_legend = []                         # empty list that should hold legends for plot
      #plt.figure()
      #for i in range(len(arr_mics_FFT)):
      #   data_FFT = np.fft.fft(ok_data[:,int(arr_mics_FFT[i])])
      #   energy = abs(data_FFT)**2
      #   freq = np.fft.fftfreq(t.shape[-1])
      #   plt.plot(fs*freq,energy)
      #   FFT_mic_legend = np.append(FFT_mic_legend,str(arr_mics_FFT[i]+1))
      #plt.suptitle('Energy of selected microphones signals')
      #plt.xlabel('Frequency [Hz]')
      #plt.legend(FFT_mic_legend)
#

     #### CALCULATE THE PHASE ####
      #mics_FFT = microphones
      #arr_mics_FFT = np.array(mics_FFT,dtype=int)-1
      #tmp=0                         # empty list that should hold legends for plot
#
      #N=1000
      #phase_diff_collection = ["" for x in range(len(arr_mics_FFT))]
#
      #for i in range(len(arr_mics_FFT)):
      #  micdata=np.fft.fft(ok_data[0:N + 1,int(arr_mics_FFT[i])])
      #  
      #  index=np.round(int(source_audio)*N/fs)  # calculate the correct bin from FFT 
      #  y=micdata[int(index)]
#
      #  if(i>0):
      #     phase_diff = np.angle(tmp/y)
      #     phase_diff = (phase_diff*180)/np.pi
      #     phase_diff=round(phase_diff,2)
      #     mic_nr = str(arr_mics_FFT[i-1]+1)+", "+str(arr_mics_FFT[i]+1)  # creates a str like this: (1,2)
      #     phase_diff_collection[i]= "\u0394\u03c6("+mic_nr+") = "+str(phase_diff)+"\u00b0"
      #  tmp=y
      #      
      #      # --- PLOT 3---
      ##   of selected microphones
#
      #plot_mics = microphones                    # what microphones to plot
      #arr_plot_mics = np.array(plot_mics)-1   # convert plot_mics to numpy array with correct index
      #mic_legend = []                         # empty list that should hold legends for plot
      #plt.figure()
      #ax=plt.subplot(111)
      #for i in range(len(arr_plot_mics)):
      #   plt.plot(ok_data[:,int(arr_plot_mics[i])], '-*')
      #   textstr= phase_diff_collection[i]
      #   mic_legend = np.append(mic_legend,"mic "+str(arr_plot_mics[i]+1)+".  "+textstr)
      #plt.xlim([0, plot_samples])
      #plt.xlabel('Samples')
      #plt.ylabel('Amplitude')
      #plt.suptitle('Selected microphones')
      #plt.legend(mic_legend)
      #
   #
      #if normalized:
      #   plt.ylim([-max_value_ok*1.1, max_value_ok*1.1])

      # Show all plots
      plt.show()

   main()
#################################################################################################
print("Enter a filename to samples: ")
#fileChooser = input()
fileChooser = "ljud"
print("Enter the frequency of the audio source (Hz): ")
#source_audio=input()
source_audio = 1000
microphones = [0]

print_analysis(fileChooser,microphones,source_audio)
     
