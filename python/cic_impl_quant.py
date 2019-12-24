from scipy import signal
import numpy as np
import matplotlib.pyplot as plt
import sys, getopt

#R = 32
#N = 1
#M = 1

NUM= 10000
FS = 200000
MAX_BITS = 16
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

def comb( ins, M, R):
  delay = np.zeros(ins.size)
  delay[M:] = ins[0:-M]
  return (ins - delay)/R*M

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

  comb_out = comb(inte_samp, M, R)

  return comb_out

def integrator_q( ins, R):
  reg = 0
  out = np.zeros(ins.size)
  for i in range(ins.size):
    out[i] = np.fmod(ins[i] + reg, 2**(MAX_BITS+R-1))
    reg = out[i]
  return out

def comb_q( ins, M, R):
  delay = np.zeros(ins.size)
  delay[M:] = ins[0:-M]
  comb_out = np.floor((ins - delay)*2**(MAX_BITS+R-1))/2**(MAX_BITS+R-1)
  comb_out_q = np.floor((comb_out/2**R)*2**(MAX_BITS-1))/2**(MAX_BITS-1)

  #comb_out = ((ins - delay)*2**(MAX_BITS+R-1))/2**(MAX_BITS+R-1)
  #comb_out_q = (comb_out)/2**R

  #comb_out = (ins - delay)
  #comb_out_q = (comb_out)/(2**R)

  return np.clip(comb_out_q,-1,(2**(MAX_BITS-1)-1)/2**(MAX_BITS-1))
  #return comb_out_q

def CIC_Q( ins, R, N, M ):
  P = int(R/2) #sample phase

  #ins_c = np.clip(ins, -1, (2**(MAX_BITS-1)-1)/2**(MAX_BITS-1))
  #ins_q = np.floor(ins_c*(2**(MAX_BITS-1)))/2**(MAX_BITS-1)

  Q = int(np.log2(R))
  inte_out = integrator_q(ins,Q)

  inte_samp = sample(inte_out, R, P)

  comb_out = comb_q(inte_samp, M, Q)

  return comb_out

def GenSin( N, F ):
  c = N/(FS/F)
  #w = np.linspace(0, 1, int(c)*N+1)
  w = np.linspace(0, 1, N+1)
  win = np.sin(c * w * 2*np.pi)
  return win

def get_att(R,N,M,F):
  sin_data = GenSin(NUM, F)

  sin_data_c = np.clip(sin_data, -1, (2**(MAX_BITS-1)-1)/2**(MAX_BITS-1))
  sin_data_q = np.floor(sin_data_c*(2**(MAX_BITS-1)))/2**(MAX_BITS-1)
  #print(sin_data[0:20])
  cic_out = CIC_Q(sin_data_q, R, N, M)
  #print(cic_out)
  return max(cic_out)


#print(get_att(2,1,1,50000))
#sin_data = GenSin(10000, 100000)
#c = 10000/(FS/100000)
#print(c)

def cic_impl(R, N, M):
  freq = FS*(2**np.linspace(-9,10,1901))
  #print(freq)
  att = np.ones(freq.size)
  i = 0;
  for f in freq:
    att[i] = get_att(R,N,M,f)
    i = i+1
    
  attdb = 10 * np.log(att+np.finfo(np.float32).tiny)

  kstr = 'R={0}, M={1}, N = {2}'.format(R, 1, 1)
  plt.plot(freq, attdb, 'b-', label=kstr)
  plt.legend()
  plt.grid()
  plt.grid(which='both',axis='x')
  plt.xlim([100, 1e6])
  plt.ylim([-90, 0])
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
