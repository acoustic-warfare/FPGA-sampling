import numpy as np
import scipy
import matplotlib.pyplot as plt
import signal_generator


def pfb_fir_frontend(x, win_coeffs, M, P):
    W = int(len(x) / M / P)
    x_p = x.reshape((W*M, P)).T
    h_p = win_coeffs.reshape((M, P)).T
    x_summed = np.zeros((P, M * W - M))
    for t in range(0, M*W-M):
        x_window = x_p[:, t:t + M]
        x_weighted = x_window * h_p
        x_summed[:, t] = x_weighted.sum(axis=1)
    return x_summed.T


def generate_win_coeffs(M, P, window_fn="hamming"):
    win_coeffs = scipy.signal.get_window(window_fn, M*P)
    sinc = scipy.signal.firwin(M * P, cutoff=1.0/P, window="rectangular")
    win_coeffs_and_sinc = win_coeffs * sinc
    return win_coeffs_and_sinc


def fft(x_p, P, axis=1):
    return np.fft.rfft(x_p, P, axis=axis)


def db(x):
    """ Convert linear value to dB value """
    return 10*np.log10(x)


Fs = 48828.125
M = 4      # Tap multiplier (taps = M * P)
P = 64     # Number of 'branches', also fft length

x = signal_generator.generate_signal()
win_coeffs = generate_win_coeffs(M, P, window_fn="hamming")

# small test with scaling and fixed point coeffs, works fine :)
win_coeffs = win_coeffs * (255 / max(win_coeffs))
win_coeffs = np.round(win_coeffs)

x_fir = pfb_fir_frontend(x, win_coeffs, M, P)

# FFT output is of width P/2+1 P=input width
x_pfb = fft(x_fir, P)

# Take the magnitude
x_psd = np.abs(x_pfb)**2

print(x_psd.shape)

plt.imshow(db(x_psd), cmap='viridis', aspect='auto')
plt.colorbar()
plt.xlabel("Channel")
plt.ylabel("Time")
plt.show()
