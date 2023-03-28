import numpy as np

from scipy.signal import chirp, spectrogram

import matplotlib.pyplot as plt




def generate_sweep():
   #t = np.linspace(0, 100, 96000)
   start_f=0       #Start frequency
   stop_f=22000      #Stop frequency
   #t1=1     
   T=10       #Time interval
   fs=88000   #sample rate assume 4*highest frecuency is enough

   t = np.arange(0, int(T*fs)) / fs

   w = chirp(t, f0=start_f, t1=T, f1=stop_f, method='linear',phi=-90)

   plt.plot(t, w)

   plt.title("Linear Chirp")

   plt.xlabel('t (sec)')

   plt.show()

def main():
   generate_sweep()

if __name__ == "__main__":
    main()
