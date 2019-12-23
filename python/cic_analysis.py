from scipy import signal
import numpy as np
import matplotlib.pyplot as plt
import sys, getopt


def CIC_ANA(R,M,N):
  Fs = 200000
  Fmax = 1e6
  w = np.linspace(1E-5, Fmax/Fs, 10000)
  f = w * Fs
  
  # R is the decimation ratio, N is the filter order, M is a free number usually 1 or 2
  #R = 64 #10
  #N = 1 #4
  #M = 1
  
  H = np.abs((np.sin(R*M*np.pi*w) / (R*M * np.sin(np.pi * w))))**N
  Hdb = 10 * np.log(H)
  kstr = 'R={0}, M={1}, N = {2}'.format(R, M, N)
  plt.plot(f, Hdb, label=kstr)
  plt.legend()
  plt.grid()
  plt.grid(which='both',axis='x')
  plt.xlim([100, 1e6])
  plt.ylim([-200, 0])
  plt.xlabel('Sampling Rate [Hz]')
  plt.ylabel('Attenuation [dB]')
  plt.xscale('log')
  plt.show()

def main(argv):
  R = 2
  N = 1
  M = 1
  try:
    opts, args = getopt.getopt(argv,"hr:n:m:")
  except getopt.GetoptError:
    print('test.py -r <over sample rate> -n[1] <number state> -m[1] <value of delay>')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print('test.py -r 2')
      sys.exit()
    elif opt in ("-r"):
      R = int(arg)
    elif opt in ("-m"):
      M = int(arg)
    elif opt in ("-n"):
      N = int(arg)
  print('R={0}, M={1}, N = {2}'.format(R, M, N))

  CIC_ANA(R,M,N)

main(sys.argv[1:])







