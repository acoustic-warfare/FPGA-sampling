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
   N = int(fs*T)         # total amount of sample points
   t = np.linspace(0, T, int(T * fs), endpoint=False)
   t_space = 1/fs

   #L is used for the modified farina sweep
   L= (1/start_f)*((T*start_f)/(np.log(stop_f/start_f)))
    #Below: sine and cos only represents the signals start phase.  try and use differen "chirp_signal"

    
   #  _______________________________Mark method_1_____________________________________ 
        # sine lin
   chirp_signal = chirp(t, f0=start_f, t1=T, f1=stop_f, method='linear',phi=-90, vertex_zero=True ) 
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
   
         #Modified Farina sweep   works
   chirp_signal = np.sin(2*np.pi*start_f*L *(np.exp(t/L)-1))
   #_________________________________________________________________________________________________________
   #creates curve at the end of signal.
   TUKEY_SAMPLES = N //16  ## number of samples to create curve at the end of chirp
   chirp_signal = tukey(chirp_signal,TUKEY_SAMPLES)
   
   #converts to int16
   chirp_signal = np.int16((chirp_signal / chirp_signal.max()) * 32767)   # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.
   
   # Plot time domain
   plt.subplot(4,1,1)
   plt.plot(t, chirp_signal)
   plt.title("Time domain - pure Chirp")
   plt.xlabel('t (sec)')
   
   #Convert to frecuency domain
   fft = np.fft.fft(chirp_signal)
   freq = np.fft.fftfreq(len(chirp_signal), t_space)
   
   # Plot Amplitude of FFT
   plt.subplot(4,1,2)
   plt.plot(freq[0:N//2], np.abs(fft)[0:N//2])
   plt.xlabel('Frequency (Hz)')
   plt.ylabel('Amplitude')
   plt.title('Frequency Domain - pure chirp')

  
   # Plot power spectrum of FFT  ---- Needs to be updated
   plt.subplot(4,1,3)
   plt.psd(chirp_signal, Fs=fs, NFFT=N, scale_by_freq=False)
   plt.xlabel('Frequency (Hz)')
   plt.ylabel('Power')
   plt.title('Power spectrum')

   # plot phase of signal 
   phase = np.unwrap(np.angle(fft))
   plt.subplot(4,1,4)
   plt.plot(t,phase)
   plt.xlabel('Frequency (Hz)')
   plt.ylabel('Phase')
   plt.show()
 
   

   return chirp_signal

def create_sound_file(normalized_tone,fs):


   write("example.wav",fs , normalized_tone)

def tukey (v, size):  ## Creates a ramp in the end of the generated chirp, to avoid side lobes 
    if len(v) < 2*size:
        raise ValueError ("Tukey window size too big for array")
    tuk = 0.5 * (1.0 - np.cos (np.pi * np.arange(size) / size))
    #v[0:size] *= tuk   # ADD his line for curve at the beginning aswell
    v[-size:] *= tuk[::-1]
    
    return v




def convolve_with_sim_IR(chirp_signal,T,N,fs):
   
   IR = 0.8                                       # creates a fake Imulse respons
   output = np.convolve(chirp_signal,IR)           # Convolve with the generated chirp

   
   time_output = np.linspace(0,T,N,endpoint=False)

   plt.subplot(2,1,1)
   plt.plot(time_output,output)
   plt.xlabel("time (s)")
   plt.ylabel("amplitude")
   plt.title("output after convolution with sim IR")
   

   # Calculate the frequency response of the convoluted output
   output_fft = np.fft.fft(output)
   chirp_fft = np.fft.fft(chirp_signal)

   #do the division explained in work of angelo Farina 2000.
   systems_frecuency_respons = np.abs(output_fft) / np.abs(chirp_fft)

   t_space= 1/fs

   #Convert to frecuency domain
   freq = np.fft.fftfreq(len(chirp_signal), t_space)
   
   # Plot Amplitude of FFT
   plt.subplot(2,1,2)
   plt.plot(freq[0:N//2], np.abs(systems_frecuency_respons)[0:N//2])
   plt.xlabel('Frequency (Hz)')
   plt.ylabel('Amplitude')
   plt.title('Frequency output after convolution')
   plt.show()
    ############ MAIN #############
if __name__ == '__main__':
   
   start_f=1         #Start frequency
   stop_f=22000      #Stop frequency   
   T=2               #Time interval
   fs=44100          #sample rate assume 4*highest frecuency is enough
   N = fs*T
   

   chirp_signal = generate_chirp(start_f,stop_f,T,fs)
   
   create_sound_file(chirp_signal,fs)

   convolve_with_sim_IR(chirp_signal,T,N,fs)
   
   
   
