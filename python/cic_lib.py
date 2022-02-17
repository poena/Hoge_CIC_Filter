import numpy as np

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

def up_sample( ins, R):
  #sample_num = (ins.size)*R
  inte_samp = np.repeat(ins,R)
  
  return inte_samp
  
def CIC( ins, R, N, M ):
  P = int(R/2) #sample phase

  inte_out = integrator(ins)

  inte_samp = sample(inte_out, R, P)

  comb_out = comb(inte_samp, M)

  return comb_out/(R*M)
