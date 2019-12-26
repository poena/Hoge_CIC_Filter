
global NUM
NUM = 10000;
global FS
FS = 200000;
%cic_impl(2,1,1);

function out_i = integrator( ins )
  reg = 0;
  out_i = zeros(1,length(ins));
  for i = (1:length(ins))
    out_i(i) = ins(i) + reg;
    reg = out_i(i);
  end
end

function out_c = comb( ins, M )
  delay = zeros(1,length(ins));
  delay(1+M:end) = ins(1:end-M);
  out_c = ins - delay;
end

function samp_out = sample( ins, R, P)
  sample_num = int32((length(ins)-P)/R);
  inte_samp = zeros(1,sample_num);
  for i = (1:sample_num)
    inte_samp(i) = ins(i*R+P);
  end
  samp_out = inte_samp;
end

  
function cic_out = CIC( ins, R, N, M )
  P = int32(R/2); %sample phase

  inte_out = integrator(ins);
  inte_samp = sample(inte_out, R, P);
  comb_out = comb(inte_samp, M);

  cic_out = comb_out./(R*M);
end

function sinout = GenSin( N, F )
  global FS
  c = N/(FS/F);
  w = (0:1/N:1);
  win = sin(c * w * 2*pi);
  sinout = win;
end


function att = get_att(R,N,M,F)
  global NUM;
  sin_data = GenSin(NUM, F);
  cic_out = CIC(sin_data, R, N, M);
  att = max(cic_out);
end


function cic_impl(R, N, M)
  global FS;
  freq = FS*(2.^(-9:1/1000:10));
  att = zeros(1,length(freq));
  i = 1;
  for f = freq
    att(i) = get_att(R,N,M,f);
    i = i+1;
  end
    
  attdb = 10 * log(att);

  kstr = ['R=',int2str(R),'M=',int2str(M), 'N=', int2str(N)];
  plot(freq, attdb, 'b-')
  title(kstr);
  %legend(kstr);
  grid();
  xlim([100, 1e6]);
  ylim([-90, 0]);
  xlabel('Sampling Rate [Hz]');
  ylabel('Attenuation [dB]');
  set(gca,'XScale','log');

end

%cic_impl(2,1,1);
