import numpy as np
import matplotlib.pyplot as plt
import sounddevice
import os
import math

def Average(l): 
    avg = sum(l) / len(l) 
    return avg

ROOT = os.getcwd()

filename = (ROOT + "/ps/mic_data/sinus_raport.txt")
mic = 46

data = np.loadtxt(open(filename, 'rb').readlines()[:-1], delimiter=',') # load data from txt file to np array
fs = data[0,2]  # sampling frequency
data = data[:,4:]    # take out mic data
total=0
mic_data=data[:,mic] 

#average = Average(mic_data)
#for i in range(len(mic_data)):
#   mic_data[i] = (mic_data[i]-average)   #substract avareg 
#   mic_data[i] = mic_data[i]*mic_data[i] #square the new value
#   total=total + mic_data[i]


#total = total/56615

#rms = math.sqrt(total) 


  
#print("Average of my_list is", average)
#print("New values: ",mic_data)
#print("RMS is : ",rms)

sound_scaled = data[:, mic]/np.max(np.abs(data[:, mic])) # normalize mic data

samples = len(data[:,0])            # number of recorded samples
t_total = samples/fs                # total time of recording
t = np.linspace(0,t_total,samples)  # time vector
data_FFT = np.fft.fft(data[:,mic])  # discrete FFT of data from one mic
nu = np.fft.fftfreq(t.shape[-1])    # normalized frequency nu


#plt.figure()
#plt.plot(fs*nu,abs(data_FFT)**2)
#plt.title('Energy of signal')
#plt.xlabel('Frequency [Hz]')
#plt.show()

sounddevice.play(sound_scaled, fs, blocking=True)
