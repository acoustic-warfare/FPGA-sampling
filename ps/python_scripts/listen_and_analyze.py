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


# This scripts listen on an port and collects array samples and then plots the graphs direcly!
# Enter a filename and how long you want to record.
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

def print_analysis(fileChooser):


   def load_data_FPGA(filename):
      #   FUNCTION TO LOAD DATA FROM .TXT FILE INTO NUMPY ARRAY 
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
      f0 = 880           # frequency of recorded sinus signal
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
      

      lab_test_mic = 1;
      initial_lab_test_sample = 10000;
      lab_test_samples = 5000;
      lab_test_data = data[initial_lab_test_sample:initial_lab_test_sample+lab_test_samples,lab_test_mic];
      lab_test_power = np.sum(np.abs(lab_test_data)* np.abs(lab_test_data))/lab_test_samples /pow(2,23)
      print("power: "+str(lab_test_power))

      staring_point = 1000    #default = 1000

      if recording_device == 'FPGA':
         ok_data = data[staring_point:,] # all data is ok


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
      
      
   #Copy these values and but in "plot_mices"

  #[1,2,4,6,7,8,9,10,11,12,13,14,15,16,
  # 17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,
  # 33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,
  # 49,50,51,52,54,55,57,58,59,60,61,62,63,64]  
            
            # --- PLOT ---
      #   of selected microphones

      plot_mics = [49,50,51,52,53,54,55,56]                     # what microphones to plot
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

      # --- PLOT ---of FFT of one signal
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
#################################################################################################
print("Enter a filename to samples: ")
fileChooser = input()
print("Enter time to record (seconds): ")
recordTime=input()

while(1):
   collect_samples(fileChooser,recordTime)
   print_analysis(fileChooser)
     