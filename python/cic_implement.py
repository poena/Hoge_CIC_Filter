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

  print('max integrator {}'.format(max(out)))
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

  return comb_out/R

def GenSin( N, F ):
  c = FS/F
  w = np.linspace(0, 1, int(c)*N+1)
  win = np.sin(c * w * np.pi)
  return win

def main():
  R = 32
  N = 1
  M = 1

  print("CIC Implement with R={0}, N={1}, M={2}!".format(R,N,M))
  sin_data = GenSin(NUM, 1000)
  cic_out = CIC(sin_data, R, N, M)
  #print(sin_data.size)
  #print(cic_out.size)

  print(max(cic_out))


  t = np.linspace(0, 1, 4*NUM+1)
  P = int(R/2) #sample phase
  ts = sample(t, R, P)

  cic_out_delay = np.zeros(cic_out.size)
  cic_out_delay[P:] = cic_out[0:-P]
  #print(t.size)
  #print(ts.size)
  #print(sin_data.size)
  #print(cic_out.size)
  plt.plot(t, sin_data[0:t.size], 'r', label='sin(t)')
  plt.plot(ts, cic_out_delay[0:ts.size], 'b-', label='cic_out')
  plt.legend()
  plt.grid()
  plt.ylim([-1.2, 1.2])
  plt.xlabel('Time [s]')
  plt.ylabel('Attenuation [V]')
  plt.show()

    
main()

