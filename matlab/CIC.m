  
function cic_out = CIC( ins, R, N, M )
  %R: oversample value
  %N: stage number
  %M: delay
  P = int64(floor(R/2)); %sample phase

  inte_out = integrator(ins);
  inte_samp = sample(inte_out, R, P);
  comb_out = comb(inte_samp, M);

  cic_out = comb_out./(R*M);
end


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
  %len = double(length(ins));
  %disp([len, P,R,floor((len-double(P))/double(R))]);
  %disp(length(ins));
  %sample_num = int64(floor((length(ins)-double(P))/double(R)));
  sample_num = floor(length(ins)/R);
  %disp(sample_num)
  inte_samp = zeros(1,sample_num);
  for i = (1:sample_num)
    %disp(i);
    inte_samp(i) = ins(i*R);
  end
  samp_out = inte_samp;
end


