#!/usr/bin/env python

import csv
import numpy as np
import matplotlib.pyplot as plt
import scipy.io.wavfile as wf
import os.path

plt.close('all')

def checkfile():
    flist =[]
    for i in [1,2,3,4,5,6]:
        fname = './cic_out_'+str(i)+'.csv'
        if os.path.isfile(fname):
            flist.append(fname)
        else:
            print("file {} is not exist.".format(fname))
    return flist

def csv2list( csvfile ):
    with open(csvfile) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        line_count = 0
        for row in csv_reader:
            length = len(row)
            data = []
            for i in range(length):
                if(len(row[i])):
                    data.append(int(row[i]));
            line_count += 1
    return data

def dbfft(x, fs, win=None, ref=32768):
    """
    Calculate spectrum in dB scale
    Args:
        x: input signal
        fs: sampling frequency
        win: vector containing window samples (same length as x).
        If not provided, then rectangular window is used by default.
        ref: reference value used for dBFS scale. 32768 for int16 and 1 for float

   Returns:
        freq: frequency vector
        s_db: spectrum in dB scale
    """

    N = len(x)  # Length of input sequence

    if win is None:
        win = np.ones(N)
    if len(x) != len(win):
        raise ValueError('Signal and window must be of the same length')
    x = x * win

    # Calculate real FFT and frequency vector
    sp = np.fft.rfft(x)
    freq = np.arange((N / 2) + 1) / (float(N) / fs)

    # Scale the magnitude of FFT by window and factor of 2,
    # because we are using half of FFT spectrum.
    s_mag = np.abs(sp) * 2 / np.sum(win)
                                                                                                                                       # Convert to dBFS
    s_dbfs = 20 * np.log10(s_mag/ref)
    return freq, s_dbfs

def getSNR(testfile,plot_en=0):
    fs = 200000
    signal = csv2list(testfile)
    signal_dc = signal - np.mean(signal)
    # Take slice
    N = 2**int(np.log2(len(signal)))
    print(N)
    #win = np.hamming(N)
    win = None
    freq, s_dbfs = dbfft(signal_dc[0:N], fs, win,2**15)
    # Scale from dBFS to dB
    #K = 120
    K = 0
    s_db = s_dbfs + K
    peak = np.where(s_db > -3)
    n_db = s_db
    n_pwr = 10**(n_db/20)
    n_pwr[peak] = 0
    noise_aver = (10*np.log10(np.sum(n_pwr**2)))
    SNR = s_db[peak] - noise_aver
    print('SNDR is {0}'.format(SNR))
    if plot_en :
        plt.plot(freq, s_db)
        plt.grid(True)
        plt.xlabel('Frequency [Hz]')
        plt.ylabel('Amplitude [dB]')
        plt.show()
    return SNR[0]

def main():
    flist = checkfile()
    snr = []
    for f in flist:
        snr.append(getSNR(f,plot_en=0))
    print(snr)

if __name__ == "__main__":
    main()
