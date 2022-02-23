from scipy import signal
from scipy.optimize import curve_fit
import numpy as np
import matplotlib.pyplot as plt
import sys, getopt
from scipy.fft import fft, fftfreq
import pandas as pd

import cic_lib as cic

Fs = 19200
N = 20480
R = 384
M = 1
L = 3

def GenPulse( N, F ):
 
    w = np.zeros(N)

    w[0] = 1
    return w


# test= np.array([1,2,3,4,5,6])
# test_i = intp(test,3,0)
# print(test_i)


pulse = GenPulse(N,Fs)

l1_out = cic.CIC(pulse,320,1,1)
l1_out_ext = cic.intp(l1_out,320,1)

l2_out=cic.CIC(l1_out_ext,1,L,384)
l2_out_ext = cic.intp(l2_out,1,1)

# l3_out=cic.CIC(l2_out_ext,1,1,320)
# l3_out_ext = intp(l3_out,1,1)

pulse_out = l2_out_ext

N_O = N
#yf = fft(pulse_out)
#xf = fftfreq(N//R, 1/Fs)[:N//R//2]
#yf_db = 20*np.log10(np.abs(yf[0:N//R//2]))

yf = fft(pulse_out)
xf = fftfreq(N_O, 1/Fs)[:N_O//2]
yf_db = 20*np.log10(np.abs(yf[0:N_O//2]))

plt.plot(xf, yf_db)
#plt.plot(pulse, 'b-', label="pulse in")
#plt.plot(pulse_out, 'g-', label="pulse out")
#plt.legend()
plt.grid()
#plt.grid(which='both',axis='x')
plt.xlim([0, 150])
plt.ylim([-120, 0])
#plt.xlabel('Sampling Rate [Hz]')
#plt.ylabel('Attenuation [dB]')
#plt.xscale('log')
plt.show()