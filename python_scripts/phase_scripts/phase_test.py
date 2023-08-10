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
# Pick a horizontal line or a vertical line.
# the plotted graphs will show
# to make a new recording simply close all the graphs and a new session is started. 



def collect_samples(filename,recordtime):
   # NOTE: Check if big-endian or little-endian as this is often flipped
   # use:
   # from ctypes import LittleEndianStructure, BigEndianStructure
   # and replace Structure with LittleEndianStructure or BigEndianStructure to get the right one.
   class Data(Structure):
    _fields_ = [
        ("header", c_int32),
        ("sampelCounter", c_int32),
        ("mic_1", c_int32), ("mic_2", c_int32), ("mic_3", c_int32), ("mic_4", c_int32), (
            "mic_5", c_int32), ("mic_6", c_int32), ("mic_7", c_int32), ("mic_8", c_int32),
        ("mic_9", c_int32), ("mic_10", c_int32), ("mic_11", c_int32), ("mic_12", c_int32), (
            "mic_13", c_int32), ("mic_14", c_int32), ("mic_15", c_int32), ("mic_16", c_int32),
        ("mic_17", c_int32), ("mic_18", c_int32), ("mic_19", c_int32), ("mic_20", c_int32), ("mic_21", c_int32), ("mic_22", c_int32), ("mic_23", c_int32), ("mic_24", c_int32), (
            "mic_25", c_int32), ("mic_26", c_int32), ("mic_27", c_int32), ("mic_28", c_int32), ("mic_29", c_int32), ("mic_30", c_int32), ("mic_31", c_int32), ("mic_32", c_int32),
        ("mic_33", c_int32), ("mic_34", c_int32), ("mic_35", c_int32), ("mic_36", c_int32), ("mic_37", c_int32), ("mic_38", c_int32), ("mic_39", c_int32), ("mic_40", c_int32), (
            "mic_41", c_int32), ("mic_42", c_int32), ("mic_43", c_int32), ("mic_44", c_int32), ("mic_45", c_int32), ("mic_46", c_int32), ("mic_47", c_int32), ("mic_48", c_int32),
        ("mic_49", c_int32), ("mic_50", c_int32), ("mic_51", c_int32), ("mic_52", c_int32), ("mic_53", c_int32), ("mic_54", c_int32), ("mic_55", c_int32), ("mic_56", c_int32), (
            "mic_57", c_int32), ("mic_58", c_int32), ("mic_59", c_int32), ("mic_60", c_int32), ("mic_61", c_int32), ("mic_62", c_int32), ("mic_63", c_int32), ("mic_64", c_int32),
        ("mic_65", c_int32), ("mic_66", c_int32), ("mic_67", c_int32), ("mic_68", c_int32), ("mic_69", c_int32), ("mic_70", c_int32), ("mic_71", c_int32), ("mic_72", c_int32), (
            "mic_73", c_int32), ("mic_74", c_int32), ("mic_75", c_int32), ("mic_76", c_int32), ("mic_77", c_int32), ("mic_78", c_int32), ("mic_79", c_int32), ("mic_80", c_int32),
        ("mic_81", c_int32), ("mic_82", c_int32), ("mic_83", c_int32), ("mic_84", c_int32), ("mic_85", c_int32), ("mic_86", c_int32), ("mic_87", c_int32), ("mic_88", c_int32), (
            "mic_89", c_int32), ("mic_90", c_int32), ("mic_91", c_int32), ("mic_92", c_int32), ("mic_93", c_int32), ("mic_94", c_int32), ("mic_95", c_int32), ("mic_96", c_int32),
        ("mic_97", c_int32), ("mic_98", c_int32), ("mic_99", c_int32), ("mic_100", c_int32), ("mic_101", c_int32), ("mic_102", c_int32), ("mic_103", c_int32), ("mic_104", c_int32), (
            "mic_105", c_int32), ("mic_106", c_int32), ("mic_107", c_int32), ("mic_108", c_int32), ("mic_109", c_int32), ("mic_110", c_int32), ("mic_111", c_int32), ("mic_112", c_int32),
        ("mic_113", c_int32), ("mic_114", c_int32), ("mic_115", c_int32), ("mic_116", c_int32), ("mic_117", c_int32), ("mic_118", c_int32), ("mic_119", c_int32), ("mic_120", c_int32), (
            "mic_121", c_int32), ("mic_122", c_int32), ("mic_123", c_int32), ("mic_124", c_int32), ("mic_125", c_int32), ("mic_126", c_int32), ("mic_127", c_int32), ("mic_128", c_int32),
        ("mic_129", c_int32), ("mic_130", c_int32), ("mic_131", c_int32), ("mic_132", c_int32), ("mic_133", c_int32), ("mic_134", c_int32), ("mic_135", c_int32), ("mic_136", c_int32), (
            "mic_137", c_int32), ("mic_138", c_int32), ("mic_139", c_int32), ("mic_140", c_int32), ("mic_141", c_int32), ("mic_142", c_int32), ("mic_143", c_int32), ("mic_144", c_int32),
        ("mic_145", c_int32), ("mic_146", c_int32), ("mic_147", c_int32), ("mic_148", c_int32), ("mic_149", c_int32), ("mic_150", c_int32), ("mic_151", c_int32), ("mic_152", c_int32), (
            "mic_153", c_int32), ("mic_154", c_int32), ("mic_155", c_int32), ("mic_156", c_int32), ("mic_157", c_int32), ("mic_158", c_int32), ("mic_159", c_int32), ("mic_160", c_int32),
        ("mic_161", c_int32), ("mic_162", c_int32), ("mic_163", c_int32), ("mic_164", c_int32), ("mic_165", c_int32), ("mic_166", c_int32), ("mic_167", c_int32), ("mic_168", c_int32), (
            "mic_169", c_int32), ("mic_170", c_int32), ("mic_171", c_int32), ("mic_172", c_int32), ("mic_173", c_int32), ("mic_174", c_int32), ("mic_175", c_int32), ("mic_176", c_int32),
        ("mic_177", c_int32), ("mic_178", c_int32), ("mic_179", c_int32), ("mic_180", c_int32), ("mic_181", c_int32), ("mic_182", c_int32), ("mic_183", c_int32), ("mic_184", c_int32), (
            "mic_185", c_int32), ("mic_186", c_int32), ("mic_187", c_int32), ("mic_188", c_int32), ("mic_189", c_int32), ("mic_190", c_int32), ("mic_191", c_int32), ("mic_192", c_int32),
        ("mic_193", c_int32), ("mic_194", c_int32), ("mic_195", c_int32), ("mic_196", c_int32), ("mic_197", c_int32), ("mic_198", c_int32), ("mic_199", c_int32), ("mic_200", c_int32), (
            "mic_201", c_int32), ("mic_202", c_int32), ("mic_203", c_int32), ("mic_204", c_int32), ("mic_205", c_int32), ("mic_206", c_int32), ("mic_207", c_int32), ("mic_208", c_int32),
        ("mic_209", c_int32), ("mic_210", c_int32), ("mic_211", c_int32), ("mic_212", c_int32), ("mic_213", c_int32), ("mic_214", c_int32), ("mic_215", c_int32), ("mic_216", c_int32), (
            "mic_217", c_int32), ("mic_218", c_int32), ("mic_219", c_int32), ("mic_220", c_int32), ("mic_221", c_int32), ("mic_222", c_int32), ("mic_223", c_int32), ("mic_224", c_int32),
        ("mic_225", c_int32), ("mic_226", c_int32), ("mic_227", c_int32), ("mic_228", c_int32), ("mic_229", c_int32), ("mic_230", c_int32), ("mic_231", c_int32), ("mic_232", c_int32), (
            "mic_233", c_int32), ("mic_234", c_int32), ("mic_235", c_int32), ("mic_236", c_int32), ("mic_237", c_int32), ("mic_238", c_int32), ("mic_239", c_int32), ("mic_240", c_int32),
        ("mic_241", c_int32), ("mic_242", c_int32), ("mic_243", c_int32), ("mic_244", c_int32), ("mic_245", c_int32), ("mic_246", c_int32), ("mic_247", c_int32), ("mic_248", c_int32), (
            "mic_249", c_int32), ("mic_250", c_int32), ("mic_251", c_int32), ("mic_252", c_int32), ("mic_253", c_int32), ("mic_254", c_int32), ("mic_255", c_int32), ("mic_256", c_int32),
    ]
    
   UDP_IP = "0.0.0.0"
   UDP_PORT = 21844

   
   t_end = time.time()+int(recordtime)


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

def print_analysis(fileChooser,microphones,source_audio,recordtime):


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


      plot_samples = math.floor(plot_period*(fs/f0))                     # number of samples to plot, to use for axis scaling
      max_value_ok = np.max(np.max(ok_data[0:4000,],axis=0)) # maximum value of data, to use for axis scaling in plots

      print('sample frequency: '+ str(int(fs)))
      
      
      #### EXPECTED PHASE DIFF ####
      t_diff = 0.02/340
      expected_phase_diff = 360*t_diff*int(source_audio)
      #expected_phase_diff = np.round(expected_phase_diff,2)

      #### CALCULATE THE REAL PHASE DIFF ####
      mics_FFT = microphones
      arr_mics_FFT = np.array(mics_FFT,dtype=int)-1
      tmp=0                         # empty list that should hold legends for plot

      N=N=len(ok_data[:,0]) 
      phase_diff_collection = ["" for x in range(len(arr_mics_FFT))]
      first_mic = np.fft.fft(ok_data[0:N,int(arr_mics_FFT[0])])
      index=np.round(int(source_audio)*N/fs)
      first_mic_fft = first_mic[int(index)]

      for i in range(len(arr_mics_FFT)):
        micdata=np.fft.fft(ok_data[0:N,int(arr_mics_FFT[i])])
        
        #index=np.round(int(source_audio)*N/fs)  # calculate the correct bin from FFT 
        y=micdata[int(index)]

        if(i>=0):
           phase_diff = np.angle(first_mic_fft/y)
           phase_diff = (phase_diff*180)/np.pi
           phase_diff=round(phase_diff,2)
           mic_nr = str(arr_mics_FFT[0]+1)+", "+str(arr_mics_FFT[i]+1)  # creates a str like this: (1,2)
           phase_diff_collection[i]= "\u0394\u03c6("+mic_nr+") = "+str(phase_diff)+"\u00b0.   expected ("+str(np.round(expected_phase_diff*i,2))+"\u00b0)"
        #tmp=y
            
            # --- PLOT 3---
      #   of selected microphones

      plot_mics = microphones                    # what microphones to plot
      arr_plot_mics = np.array(plot_mics)-1   # convert plot_mics to numpy array with correct index
      mic_legend = []                         # empty list that should hold legends for plot
      plt.figure()
      ax=plt.subplot(111)
      for i in range(len(arr_plot_mics)):
         plt.plot(ok_data[:,int(arr_plot_mics[i])], '-*')
         textstr= phase_diff_collection[i]
         mic_legend = np.append(mic_legend,"mic "+str(arr_plot_mics[i]+1)+".  "+textstr)
      plt.xlim([0, plot_samples])
      plt.xlabel('Samples')
      plt.ylabel('Amplitude')
      plt.suptitle('Selected microphones')
      plt.legend(mic_legend)
      
   
      if normalized:
         plt.ylim([-max_value_ok*1.1, max_value_ok*1.1])

      # Show all plots
      plt.show()
      

   main()
#################################################################################################
print("Enter a filename to samples: ")
fileChooser = input()
print("Enter time to record (seconds): ")
recordtime=input()
print("Enter the frequency of the audio source (Hz): ")
source_audio=input()
while(True):
   print("view data for a Horizontal line or vertical line. Enter [H/V]")
   choise=input()
   choise=choise.lower()
   microphones=[0,0,0,0,0,0,0,0]
   if(choise=='h'):
      while(True):
         print("pick a horizontal line[Lx]")
         print("_____________________________________ ")
         print("L1: | 8, 7, 6, 5, 4, 3, 2, 1")
         print("L2: | 9,10,11,12,13,14,15,16 ")
         print("L3: | 24,23,22,21,20,19,18,17")
         print("L4: | 25,26,27,28,29,30,31,32")
         print("L5: | 40,39,38,37,36,35,34,33")
         print("L6: | 41,42,43,44,45,46,47,48")
         print("L7: | 56,55,54,53,52,51,50,49")
         print("L8: | 57,58,59,60,61,62,63,64")
         print("\n")
         print("write [Lx], where x is a number from 1-8")
         print("choice: ")
         l = input()
         l = l.lower()

         if(l=="l1"):
            #8, 7, 6, 5, 4, 3, 2, 1
            #9,10,11,12,13,14,15,16
            #24,23,22,21,20,19,18,17
            #25,26,27,28,29,30,31,32
            #40,39,38,37,36,35,34,33
            #56,55,54,53,52,51,50,49
            #57,58,59,60,61,62,63,64
            microphones=[8, 7, 6, 5, 4, 3, 2, 1]
            break
         elif(l=="l2"):
            microphones=[9,10,11,12,13,14,15,16]
            break
         elif(l=="l3"):
            microphones=[24,23,22,21,20,19,18,17]
            break
         elif(l=="l4"):
            microphones=[25,26,27,28,29,30,31,32]
            break
         elif(l=="l5"):
            microphones=[40,39,38,37,36,35,34,33]
            break
         elif(l=="l6"):
            microphones=[41,42,43,44,45,46,47,48]
            break
         elif(l=="l7"):
            microphones=[56,55,54,53,52,51,50,49]
            break
         elif(l=="l8"):
            microphones=[57,58,59,60,61,62,63,64]
            break
         else:
            print("invalid input. write [Lx], where x is a number from 1-8")
      break
############################################################################# fixa
   elif(choise=="v"):
      while(True):
         print("pick a vertical Line[Lx]")
         print("L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 |")
         print("---------------------------------------")
         print("8  | 7  | 6  | 5  | 4  | 3  | 2  | 1  |")
         print("9  | 10 | 11 | 12 | 13 | 14 | 15 | 16 |")
         print("24 | 23 | 22 | 21 | 20 | 19 | 18 | 17 |")
         print("25 | 26 | 27 | 28 | 29 | 30 | 31 | 32 |")
         print("40 | 39 | 38 | 37 | 36 | 35 | 34 | 33 |")
         print("41 | 42 | 43 | 44 | 45 | 46 | 47 | 48 |")
         print("56 | 55 | 54 | 53 | 52 | 51 | 50 | 49 |")
         print("57 | 58 | 59 | 60 | 61 | 62 | 63 | 64 |")
         print("\n")
         print("write [Lx], where x is a number from 1-8")
         print("choice: ")
         v = input()
         v = v.lower()
         if(v=="l1"):
            microphones=[8,9,24,25,40,41,56,57]
            break
         elif(v=="l2"):
            microphones=[7,10,23,26,39,42,55,58]
            break
         elif(v=="l3"):
            microphones=[6,11,22,27,38,43,54,59]
            break
         elif(v=="l4"):
            microphones=[5,12,21,28,37,44,53,60]
            break
         elif(v=="l5"):
            microphones=[4,13,20,29,36,45,52,61]
            break
         elif(v=="l6"):
            microphones=[3,14,19,30,35,46,51,62]
            break
         elif(v=="l7"):
            #15,2,31,18,47,34,
            microphones=[2,15,18,31,34,47,50,63]
            break
         elif(v=="l8"):
            
            microphones=[1,16,17,32,33,48,49,64]
            break
         else:
            print("invalid input. write [Lx], where x is a number from 1-8")
      break
   else:
      print("invalid input. write [H] for Horizontal and or [V] for vertical")

#print("press ENTER to start")
input("press ENTER to start")

   

while(1):
   collect_samples(fileChooser,recordtime)
   print_analysis(fileChooser,microphones,source_audio,recordtime)
     
