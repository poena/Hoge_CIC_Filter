from scipy import signal
import numpy as np
import matplotlib.pyplot as plt
import sys, getopt

#R = 32
#N = 1
#M = 1

NUM= 10000
FS = 200000
#w = np.linespace(1/NUM, 1, NUM)
#win = np.sin(2 * w * np.pi)


def integrator( ins ):
  reg = 0
  out = np.zeros(ins.size)
  for i in range(ins.size):
    out[i] = ins[i] + reg
    reg = out[i]

  #print('max integrator {}'.format(max(out)))
  return out

def comb( ins, M ):
  delay = np.zeros(ins.size)
  delay[M:] = ins[0:-M]
  return ins - delay

def sample( ins, R, P):
  sample_num = int((ins.size-P)/R)
  inte_samp = np.zeros(sample_num)
  for i in range(sample_num):
    inte_samp[i] = ins[i*R+P]
  return inte_samp

  
def CIC( ins, R, N, M ):
  P = int(R/2) #sample phase

  inte_out = integrator(ins)

  inte_samp = sample(inte_out, R, P)

  comb_out = comb(inte_samp, M)

  return comb_out/(R*M)

def GenSin( N, F ):
  c = N/(FS/F)
  #w = np.linspace(0, 1, int(c)*N+1)
  w = np.linspace(0, 1, N+1)
  win = np.sin(c * w * 2*np.pi)
  return win

def plot(R,N,M,F):
  #R = 2
  #N = 1
  #M = 1
  #F = 100

  print("CIC Implement with R={0}, N={1}, M={2}!".format(R,N,M))
  sin_data = GenSin(NUM, F)
  cic_out = CIC(sin_data, R, N, M)
  #print(sin_data.size)
  #print(cic_out.size)

  #print(max(cic_out))

  t = np.linspace(0, 1, 4*int(NUM/(FS/F))+1)
  P = int(R/2) #sample phase
  PP = int(P/(FS/1000))
  #print(FS/F)
  ts = sample(t, R, P)

  #cic_out_delay = np.zeros(cic_out.size)
  #cic_out_delay[PP:] = cic_out[0:cic_out.size-PP]
  #print(t.size)
  #print(ts.size)
  #print(sin_data.size)
  #print(cic_out.size)
  plt.plot(t/(FS/1000), sin_data[0:t.size], 'r', label='sin(t)')
  plt.plot(ts/(FS/1000), cic_out[0:ts.size], 'b-', label='cic_out')
  #plt.plot(ts/(FS/1000), cic_out_delay[0:ts.size], 'b-', label='cic_out')
  plt.legend()
  plt.grid()
  plt.ylim([-1.2, 1.2])
  plt.xlabel('Time [ms]')
  plt.ylabel('Attenuation [V]')
  plt.show()

def get_att(R,N,M,F):
  sin_data = GenSin(NUM, F)
  #print(sin_data[0:20])
  cic_out = CIC(sin_data, R, N, M)
  #print(cic_out)
  return max(cic_out)


#print(get_att(2,1,1,50000))
#sin_data = GenSin(10000, 100000)
#c = 10000/(FS/100000)
#print(c)

def cic_impl(R, N, M):
  freq = FS*(2**np.linspace(-9,10,1901))
  #print(freq)
  att = np.zeros(freq.size)
  i = 0;
  for f in freq:
    att[i] = get_att(R,N,M,f)
    i = i+1
    
  attdb = 10 * np.log(att)

  kstr = 'R={0}, M={1}, N = {2}'.format(R, 1, 1)
  plt.plot(freq, attdb, 'b-', label=kstr)
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
    print('cic_implement.py -r <over sample rate> -n[1] <number state> -m[1] <value of delay>')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print('cic_implement.py -r 2')
      sys.exit()
    elif opt in ("-r"):
      R = int(arg)
    elif opt in ("-m"):
      M = int(arg)
    elif opt in ("-n"):
      N = int(arg)
  print('R={0}, M={1}, N = {2}'.format(R, M, N))

  cic_impl(R,N,M)

main(sys.argv[1:])

'''
r = 4
MIN = 1e2
MAX = 1e6
MINe = int(np.log2(MIN/FS)-1)
MAXe = int(np.log2(MAX/FS)+1)
freq = FS*(2**np.linspace(-9,10,1901))
print(freq)
att = np.zeros(freq.size)
i = 0;
for f in freq:
  att[i] = get_att(r,1,1,f)
  i = i+1
    
Attdb = 10 * np.log(att)
print(max(Attdb))
print(min(Attdb))
#print(att)
kstr = 'R={0}, M={1}, N = {2}'.format(r, 1, 1)
plt.plot(freq, Attdb, 'b-', label=kstr)
plt.legend()
plt.grid()
plt.grid(which='both',axis='x')
plt.xlim([MIN, MAX])
plt.ylim([-200, 0])
plt.xlabel('Sampling Rate [Hz]')
plt.ylabel('Attenuation [dB]')
plt.xscale('log')
plt.show()
#main()
'''
