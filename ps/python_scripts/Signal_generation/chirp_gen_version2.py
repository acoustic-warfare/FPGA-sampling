import numpy as np

from scipy.signal import chirp, spectrogram,butter
from scipy.io.wavfile import write
from scipy.fft import fft, fftfreq

import scipy.signal
import matplotlib.pyplot as plt




def generate_chirp(start_f,stop_f,T,fs):
    
   start_f=start_f       #Start frequency
   stop_f=stop_f         #Stop frequency   
   T=T                   #Time interval
   fs=fs                 #sample rate assume 4*highest frecuency is enough
   N = int(fs*T)         # total amount of sample points
   t = np.linspace(0, T, int(T * fs), endpoint=False)
   t_space = 1/fs

   

   #normalisation factor used for inverse filter/matched filter
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
   
         #Modified Farina sweep   works ________________________________
   #L is used for the modified farina sweep
   #L= (1/start_f)*((T*start_f)/(np.log(stop_f/start_f)))
   #chirp_signal = np.sin(2*np.pi*start_f*L *(np.exp(t/L)-1))
   #_________________________________________________________________________________________________________
   
   
   
   
   #creates curve at the end of signal.
   TUKEY_SAMPLES = N //16  ## number of samples to create curve at the end of chirp
   #chirp_signal = tukey(chirp_signal,TUKEY_SAMPLES)

   ##_________________PICK INVERSE OR MATCHED FILTER________________________

   #converts to int16
   #chirp_signal = np.int16((chirp_signal / chirp_signal.max()) * 32767)   # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.
   
   #create the inverse filter version
   R = np.log(stop_f/start_f)
   k = np.exp(t*R/T)
   #inverse_filter =  chirp_signal[::-1]/k

   #matched filter
   inverse_filter = np.conj(chirp_signal[::-1])

   chirp_signal_dirac=np.convolve(chirp_signal,inverse_filter,mode='same')  

   chirp_signal_dirac = chirp_signal_dirac/np.max(np.abs(chirp_signal_dirac))  # Normalized to have the same amplitude as the generated chirp

   #chirp_signal_dirac=chirp_signal_dirac*0.5
   # Plot time domain
   plt.subplot(4,1,1)
   #plt.figure()
   plt.plot(t, chirp_signal)
   plt.title("Time_domain - pure Chirp")
   plt.xlabel('t (sec)')


   #plot inverse filter
   plt.subplot(4,1,2)
   #plt.figure()
   plt.plot(t, inverse_filter)
   plt.title("Time domain - inversed filter")
   plt.xlabel('t (sec)')
   
   #Convert to frecuency domain
   fft_chirp = np.fft.fft(chirp_signal)
   freq = np.fft.fftfreq(len(chirp_signal), t_space)
   
   
   # Plot Amplitude of FFT
   plt.subplot(4,1,3)
   #plt.figure()
   plt.plot(freq[0:N//2],np.abs(fft_chirp)[0:N//2])
   plt.xlabel('Frequency (Hz)')
   plt.ylabel('Amplitude')
   plt.title('Frequency Domain - pure chirp')

   # plot time-domain IR
   plt.subplot(4,1,4)
   plt.plot(t,chirp_signal_dirac)
   plt.xlabel("time (s)")
   plt.ylabel("amplitude")
   plt.title("The IR of the (pure chirp * inverse-filter) NORMALIZED")


  
   # Plot power spectrum of FFT  ---- Needs to be updated
   #plt.subplot(4,1,4)
   #plt.psd(chirp_signal, Fs=fs, NFFT=N, scale_by_freq=False)
   #plt.xlabel('Frequency (Hz)')
   #plt.ylabel('Power')
   #plt.title('Power spectrum')

   # plot phase of signal 
   #phase = np.unwrap(np.angle(fft_chirp))
   #plt.subplot(4,1,4)
   ##plt.figure()
   #plt.plot(t,phase)
   #plt.xlabel('Frequency (Hz)')
   #plt.ylabel('Phase')
   plt.tight_layout()
   plt.show()

   

   

   return chirp_signal,inverse_filter

def create_sound_file(signal,fs,name):

   #converts to int16
   signal = np.int16((signal / signal.max()) * 32767)   # normalized to fit targetet format for n bit use (2^(n)/2  -1) = 32767 for 16bit. #this value sets the amplitude.

   write(name,fs , signal)

def tukey (v, size):  ## Creates a ramp in the end of the generated chirp, to avoid side lobes 
    if len(v) < 2*size:
        raise ValueError ("Tukey window size too big for array")
    tuk = 0.5 * (1.0 - np.cos (np.pi * np.arange(size) / size))
    #v[0:size] *= tuk   # ADD his line for curve at the beginning aswell
    v[-size:] *= tuk[::-1]
    
    return v


def convolve_with_sim_IR(chirp_signal,T,N,fs,inverse_filter):
   
   
   #Generate Noise  
   noise = np.random.normal(loc=0, scale=0.5, size=len(chirp_signal))
   chirp_with_noise = noise + chirp_signal
   output = chirp_with_noise
   #fake_IR = 0.8*chirp                                       # creates a fake Imulse respons
   #fake_IR =0.8                         #change the left value for simulating an impulse response
   #output = np.convolve(chirp_signal,noise,mode='same')           # simulates the output of a microphone

   # create the amplitude sweep          #Fully optional, remove if necessary
   amplitude_start = 0.1
   amplitude_end = 5
   a_t = np.linspace(amplitude_start, amplitude_end, N,endpoint=False)
   #output = a_t*output

   #Apply a bandpass filter to simulate a varying frequency response the mic
   f_low = 100  # Lower frequency of the passband (Hz)
   f_high = 4000  # Upper frequency of the passband (Hz)
   nyquist = fs / 2  # Nyquist frequency (Hz)
   order = 1  # Order of the filter

   # Compute the filter coefficients
   b, a = scipy.signal.butter(order, [f_low / nyquist, f_high / nyquist], btype='bandpass')

   # Apply the filter to the signal
   #output = scipy.signal.lfilter(b, a, chirp_with_noise)                     #this line applies the filter



   time_output = np.linspace(0,T,N,endpoint=False)

   #plot time domain of recorded signal(sim)
   plt.subplot(4,1,1)
   plt.plot(time_output,output)
   plt.xlabel("time (s)")
   plt.ylabel("amplitude")
   plt.title("Microphine recording (sim)")

   #plot magnitude spectrum of recorded signal(sim)
   output_fft=np.fft.fft(output)
   t_space = 1/fs
   output_fft_freq = np.fft.fftfreq(len(output), t_space)
   plt.subplot(4,1,2)
   plt.plot(output_fft_freq[0:N//2],np.abs(output_fft)[0:N//2])
   plt.xlabel("f (Hz)")
   plt.ylabel("amplitude")
   plt.title("Magnitude spectrum of recorded(sim)")
   #convolution of chirp and the inverse filter
   #impulse_of_chirp_and_filter= np.convolve(chirp_signal,inverse_filter,mode='same')

   #plt.subplot(3,1,2)
   #plt.plot(time_output,impulse_of_chirp_and_filter)
   #plt.xlabel("time (s)")
   #plt.ylabel("amplitude")
   #plt.title("Inverse filter response of pure chirp")


   t_space = 1/fs
   #fft_chirp_and_filter = np.fft.fft(impulse_of_chirp_and_filter)
   freq_chirp_and_filter = np.fft.fftfreq(len(chirp_signal), t_space)
   
   

   #plt.subplot(4,1,3)
   #plt.plot(freq_chirp_and_filter[0:N//2],np.abs(fft_chirp_and_filter)[0:N//2])
   #plt.xlabel("f (Hz)")
   #plt.ylabel("amplitude")
   #plt.title("Inverse filter respons of chirp (frequence spectrum)")

   #_____________________________#RECIEVE IMPULSE RESPONS METHOD 1. FARINA h(t)=y(t)*x(t)_________________________________________________________
   system_IR_Farina= np.convolve(output,inverse_filter,mode='same')

   system_IR_Farina = system_IR_Farina/(np.max(np.abs(system_IR_Farina)))

   system_IR_fft_Farina = np.fft.fft(system_IR_Farina)
   freq = np.fft.fftfreq(len(system_IR_Farina), t_space)

   # plot time-domain IR
   plt.subplot(4,1,3)
   plt.plot(time_output,system_IR_Farina)
   plt.xlabel("time (s)")
   plt.ylabel("amplitude")
   plt.title("The IR of the system (recording * inverse-filter)  NORMALIZED"  )


   ## Plot Amplitude of FFT
   plt.subplot(4,1,4)                                                                  #needs to be changed in order to plot
   plt.plot(freq[0:N//2], np.abs(system_IR_fft_Farina)[0:N//2])
   plt.xlabel('Frequency (Hz)')
   plt.ylabel('Amplitude')
   plt.title('The FR of the system (recording * inverse-filter)')
   #_____________________________________________________________________________________________________________________________________________
   
   
   #____________________________#RECIEVE IMPULSE RESPONS METHOD 2. division in frequency domain______________________________________________
   #output_fft = np.fft.fft(output)
   #chirp_fft = np.fft.fft(chirp_signal)
##
   ##do the division explained in work of angelo Farina 2000. __________________________________________________ #Not very useful atm
   #division_IR_fft = output_fft / chirp_fft
##
   #division_IR_time=np.fft.ifft(division_IR_fft)
   #freq = np.fft.fftfreq(len(output), t_space)
   #
   ## plot time-domain IR
   #plt.subplot(4,1,3)
   #plt.plot(time_output,division_IR_time)
   #plt.xlabel("time (s)")
   #plt.ylabel("amplitude")
   #plt.title("The IR if the system (recording * inverse-filter)")
   #
   ##t_space= 1/fs
##
   ###Convert to frecuency domain
   ##freq = np.fft.fftfreq(len(chirp_signal), t_space)
   ##
   ### Plot Amplitude of FFT
   #plt.subplot(4,1,4)                                                                  #needs to be changed in order to plot
   #plt.plot(freq[0:N//2], np.abs(division_IR_fft)[0:N//2])
   #plt.xlabel('Frequency (Hz)')
   #plt.ylabel('Amplitude')
   #plt.title('Frequency spectrum of IR')
   ##__________________________________________________________________________________________________________
   
   

   plt.tight_layout()
   plt.show()

   return output


def calibrate(output_mic,T,N):
   # Multiply the specific frequency components
   # Define the range of frequencies to multiply
   
   #for x in len(output_mic):
   #   if output_mic[x] <
   fmin = 0 # minimum frequency to multiply
   fmax = 22000 # maximum frequency to multiply
   fmax=fmax*2
   output_mic_calibrated = np.fft.fft(output_mic)
   # Multiply the frequency components in the specified range
   output_mic_calibrated[fmin:fmax+1] = 6 * output_mic_calibrated[fmin:fmax+1] # multiply the amplitudes by 2
   
   # Apply the inverse Fourier transform to the resulting signal
   calibrateted = np.fft.ifft(output_mic_calibrated)

   time_output = np.linspace(0,T,N,endpoint=False)

   t_space = 1/fs
   freq = np.fft.fftfreq(len(output_mic), t_space)

   plt.subplot(2,1,1)  
   plt.plot(freq[0:N//2],np.abs(np.fft.fft(output_mic)[0:N//2]))
   plt.xlabel("f (hz)")
   plt.ylabel("amplitude")
   plt.title("recorded signal")
   
   plt.subplot(2,1,2) 
   plt.plot(freq[0:N//2], np.abs(output_mic_calibrated[0:N//2]))
   plt.xlabel("f (Hz)")
   plt.ylabel("amplitude")
   plt.title("calibration applied to recorded signal")
   
   plt.tight_layout()
   plt.show()



    ############ MAIN #############
if __name__ == '__main__':
   
   start_f=1         #Start frequency
   stop_f=22000      #Stop frequency   
   T=2               #Time interval
   fs=48828          #sample rate assume 4*highest frecuency is enough
   N = fs*T
   
   filename_pure_chip = "chirp.wav"
   file_name_sim_recording = "recording_sim.wav"

   chirp_signal,inverse_filter = generate_chirp(start_f,stop_f,T,fs)
   
   create_sound_file(chirp_signal,fs,filename_pure_chip)

   output_mic=convolve_with_sim_IR(chirp_signal,T,N,fs,inverse_filter)
   
   create_sound_file(output_mic,fs,file_name_sim_recording)

   #calibrate(output_mic,T,N)
   
