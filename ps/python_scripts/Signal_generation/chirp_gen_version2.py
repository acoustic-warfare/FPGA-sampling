import numpy as np

from scipy.signal import chirp, spectrogram
from scipy.io.wavfile import write
from scipy.fft import fft, fftfreq

import matplotlib.pyplot as plt




def generate_chirp(start_f,stop_f,T,fs):
    
   start_f=start_f       #Start frequency
   stop_f=stop_f         #Stop frequency   
   T=T                   #Time interval
   fs=fs                 #sample rate assume 4*highest frecuency is enough
   N = fs*T              # total amount of sample points
   t = np.linspace(0, T, int(T * fs), endpoint=False)
   t_space = 1/fs

    #Below: sine and cos only represents the signals start phase.  try and use differen "chirp_signal"

    
   #  _______________________________Mark method_____________________________________ 
        # sine lin
   chirp_signal = chirp(t, f0=start_f, t1=T, f1=stop_f, method='linear',phi=-90, vertex_zero=True ) 
        # sine log       
   #chirp_signal = chirp(t, f0=start_f, t1=T, f1=stop_f, method='logarithmic',phi=-90, vertex_zero=True )   
        
        # cos lin
   #chirp_signal= chirp(t, f0=start_f, t1=T, f1=stop_f, method='linear', phi=0, vertex_zero=True) 
        # cos log         
   #chirp_signal = chirp(t, f0=start_f, t1=T, f1=stop_f, method='logarithmic',phi=-90, vertex_zero=True )  
   #_________________________________________________________________________________
   
   
   
   #_______________________________linspace method__________________________________    
        #Linear sine chirp 
   #chirp_signal = np.sin(2 * np.pi * np.linspace(start_f, stop_f, N) * (t**2/2))   # according to farina
   #chirp_signal = np.sin(2 * np.pi * np.linspace(start_f, stop_f, N) * t**2)   # acording to random stackoverflow
   
        #logaritmic sine chirp
   #chirp_signal = np.sin(2 * np.pi * np.logspace(np.log10(start_f), np.log10(stop_f), N))
   
   #________________________________________________________________________________
   # Plot time domain
   plt.figure()
   plt.plot(t, chirp_signal)
   plt.title("Time domain - Chirp")
   plt.xlabel('t (sec)')
   
   #Convert to frecuency domain
   fft = np.fft.fft(chirp_signal)
   freq = np.fft.fftfreq(len(chirp_signal), t_space)
   
   # Plot Amplitude of FFT
   plt.figure()
   plt.plot(freq[0:N//2], np.abs(fft)[0:N//2])
   plt.xlabel('Frequency (Hz)')
   plt.ylabel('Amplitude')
   plt.title('Frequency Domain - chirp')

  
   # Plot power spectrum of FFT  ---- Needs to be updated
   plt.figure()
   plt.psd(chirp_signal, Fs=fs, NFFT=N, scale_by_freq=False)
   plt.xlabel('Frequency (Hz)')
   plt.ylabel('Power')
   plt.title('Power spectrum')

   plt.show()
 
   

   return chirp_signal

def create_sound_file(normalized_tone,fs):


   write("example.wav",fs , normalized_tone)


    ############ MAIN #############
if __name__ == '__main__':
   
   start_f=1       #Start frequency
   stop_f=22000      #Stop frequency   
   T=2       #Time interval
   fs=44100   #sample rate assume 4*highest frecuency is enough
   
   

   chirp_signal = generate_chirp(start_f,stop_f,T,fs)
   
   #converts to int16
   chirp_signal = np.int16((chirp_signal / chirp_signal.max()) * 32767)   # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.
   
   create_sound_file(chirp_signal,fs)
   
   
