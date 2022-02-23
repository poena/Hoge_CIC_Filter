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
  sample_num = (ins.size-P)//R;#int((ins.size-P)/R)
  inte_samp = np.zeros(sample_num)
  for i in range(sample_num):
    inte_samp[i] = ins[i*R+P]
  return inte_samp

def up_sample( ins, R):
  #sample_num = (ins.size)*R
  inte_samp = np.repeat(ins,R)
  
  return inte_samp
  
def CIC( ins, R, N, M ):
  P = 0;#int(R/2) #sample phase

  inte_out = np.zeros([N+1,np.size(ins)])
  comb_out = np.zeros([N+1,(np.size(ins)-P)//R])

  inte_out[0,:] = ins
  for i in range(N):
    inte_out[i+1,:] = integrator(inte_out[i,:])

  comb_out[0,:] = sample(inte_out[N,:], R, P)

  for j in range(N):
    comb_out[j+1,:] = comb(comb_out[j,:], M)

  return comb_out[N,:]/(R*M)**N

def intp(ins,R,mode):
    if mode==1:
        return  np.repeat(ins,R)
    elif mode ==0:
        n = np.size(ins)

        out = np.zeros((1,R*n),dtype=ins.dtype)
        out[:,::R] = ins*R
        return out.flatten()
    else:
        print("invalid mode.")
        return 0
