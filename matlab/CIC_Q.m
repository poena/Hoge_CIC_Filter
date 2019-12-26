  
function cic_out = CIC_Q( ins, R, N, M, BITS)
  %R: oversample value
  %N: stage number
  %M: delay
  P = int64(floor(R/2)); %sample phase

  inte_out = integrator_q(ins, R, BITS);
  inte_samp = sample_q(inte_out, R, P );
  comb_out = comb_q(inte_samp, M, R, BITS);
  cic_out = comb_out;
end


function out_i = integrator_q( ins, OS, BITS )
  reg = 0;
  out_i = zeros(2,length(ins));
  % 00 <==> 01 up flip
  % 11 <==> 10 down flip
  % 00 <==> 10 up flip <-> down flip
  % 01 <==> 11 up flip <-> down flip
  flag1 = 0;
  flag2 = 0;
  flag_t = 2*flag2+flag1;
  for i = (1:length(ins))
    intsum = floor(ins(i) + reg);
    ADDBITS = log2(OS)+1;
    TOTALBITS = BITS + ADDBITS -1;
    int_trunc = sign(intsum)*mod(abs(intsum),2^(TOTALBITS));
    if int_trunc ~= intsum
      flag1 = 1 - flag1;
      flag2 = (1-sign(intsum))/2;
      flag_t = 2*flag2+flag1;

      %flag_t = 1 - flag_t;
      %int_trunc = sign(int_trunc)*(abs(int_trunc) + (2^(TOTALBITS+1)));
    end
    out_i(1,i) = int_trunc;
    out_i(2,i) = flag_t;
    %out_i(3,i) = intsum;
    reg = int_trunc;
  end
end

function out_c = comb_q( ins, M, OS, BITS )
  ADDBITS = log2(OS) + 1;
  INBITS = BITS + ADDBITS - 1;
  TOTALBITS = BITS + log2(OS) - 1;

  delay = zeros(1,size(ins,2));
  delay_flag = zeros(1,size(ins,2));
  delay(1+M:end) = ins(1,1:end-M);
  %delay(1+M:end) = sign(ins(1,1:end-M)).*mod(abs(ins(1,1:end-M)),2^(INBITS));
  delay_flag(1+M:end) = ins(2,1:end-M);

  %real_in = zeros(1,size(ins,2));
  trunc_idx = find(ins(2,:) ~= delay_flag);
  real_in = ins(1,:);
  %real_in(trunc_idx) = (1-2*floor(delay_flag(trunc_idx)/2)).*(abs(real_in(trunc_idx)) + 2^INBITS);
  real_in(trunc_idx) = (1-2*floor(ins(2,trunc_idx)/2))*2^INBITS + real_in(trunc_idx);
  %real_in = sign(ins(1,:)).*mod(abs(ins(1,:)),2^(INBITS+1));

  %trunc_idx = find(ins(2,:) == 1);
  %real_in(trunc_idx) = sign(ins(1,trunc_idx)).*(abs(ins(1,trunc_idx)) + 2^(TOTALBITS));

  combsub = floor(real_in - delay);
  combsub(combsub >  (2^(TOTALBITS)-1)) =  2^(TOTALBITS) - 1;
  combsub(combsub < -(2^(TOTALBITS)  )) = -(2^(TOTALBITS));
  out_c = floor(combsub/OS);
end

function samp_out = sample_q( ins, R, P )
  sample_num = floor(size(ins,2)/R);
  inte_samp = zeros(size(ins,1),sample_num);
  for i = (1:sample_num)
    inte_samp(:,i) = ins(:,i*R);
  end
  samp_out = inte_samp;
end


