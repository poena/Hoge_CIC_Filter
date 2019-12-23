from scipy import signal
import numpy as np
import matplotlib.pyplot as plt

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

  print(max(cic_out))

  t = np.linspace(0, 1, 4*int(NUM/(FS/F))+1)
  P = int(R/2) #sample phase
  PP = int(P/(FS/1000))
  print(FS/F)
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
  cic_out = CIC(sin_data, R, N, M)
  return max(cic_out)


#print(get_att(2,1,1,100000))

r = 4
MIN = 1e2
MAX = 1e6
freq = 10**np.linspace(2,6,1001)
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

