import numpy as np

from scipy.signal import chirp, spectrogram
from scipy.io.wavfile import write
from scipy.fft import fft, fftfreq

import matplotlib.pyplot as plt




def generate_sweep(start_f,stop_f,T,fs):


   #t = np.linspace(0, 100, 96000)
   start_f=start_f       #Start frequency
   stop_f=stop_f      #Stop frequency
   #t1=1     
   T=T       #Time interval
   fs=fs  #sample rate assume 4*highest frecuency is enough
   N = fs*T   # total amount of sample points
   t = np.arange(0, int(T*fs)) / fs
   t_space = 1/fs

   w = chirp(t, f0=start_f, t1=T, f1=stop_f, method='linear',phi=-90)   # Generates the chirp 

   #converts to int16
   normalized_tone = np.int16((w / w.max()) * 32767)   # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.


   # Plot time domain
   plt.figure()
   plt.plot(t, normalized_tone)
   plt.title("Time domain - Chirp")
   plt.xlabel('t (sec)')
   

   # Plot Magnitude of FFT
   yf = np.fft.fft(normalized_tone)
   xf = np.fft.fftfreq(N,t_space)                  # N=window length,  (1/fs)=Spacing between samples 
   plt.figure()
   plt.plot(xf[0:N//2], np.abs(yf[0:N//2]))
   plt.title("Frecuency domain - amplitude")
   plt.xlabel('f (Hz)')
   plt.ylabel("amplitude")
  
   # Plot power spectrum of FFT
   power = np.abs(np.fft.fft(normalized_tone))**2
   freqs = np.fft.fftfreq(N,t)
   idx = np.argsort(freqs)
   plt.figure()
   plt.plot(freqs[idx], power[idx])
   plt.title("Frecuency domain- Chirp power")
   plt.xlabel('f (Hz)')
   plt.ylabel("Power")

   plt.show()
 
   

   return w,normalized_tone

def create_sound_file(normalized_tone,fs):


   write("example.wav",fs , normalized_tone)


    ############ MAIN #############
if __name__ == '__main__':
   
   start_f=0       #Start frequency
   stop_f=22000      #Stop frequency   
   T=2       #Time interval
   fs=48828   #sample rate assume 4*highest frecuency is enough
   N = fs*T   # total amount of sample points
   

   chirp_signal,normalized_tone = generate_sweep(start_f,stop_f,T,fs)
   create_sound_file(normalized_tone,fs)