function [SNDR,SFDR,Offset] = calSNDR_SFDR(adout,d_len,add_window, plot_flag,fs)

%����adoutΪ�����������ݣ��䳤��Ϊd_len������FFT�����������׺Ͷ�̬���Ե�MATLAB�������£�
%******************** ȥֱ������ *************************
% �����0~1023֮��仯���м���һ���ܴ��ֱ�����������������׷���ǰ����ȥ����ֱ������
% �Լ򻯼Ӵ���Ķ�ָ̬�����
Offset = mean(adout)+0.5;
adout = adout - mean(adout);                                              
%******************** add hanning window *************************
if add_window == 1
    adout = adout.*rot90(hanning(d_len)); % �����ȡ�����ݳ��Ȳ��������������ź����ڣ���Ҫ�Ӵ�������ע�͵���һ��
end
%******************** FFT�任������ ****************************
pow_spec = fft(adout).*conj(fft(adout)); %��ת�������fft���书����
pow_spec = pow_spec/max(pow_spec);   %��һ��������
d_len2 = floor(d_len/2);
pow_spec = pow_spec(1:d_len2); %���ڹ����������ҶԳƵģ�����ֻ��ȡ����벿��
%***************** ���������� *****************************************
if plot_flag==1
    xz = 0:1/d_len*fs/1000:(d_len2-1)/d_len*fs/1000;     %�����xzֻ�Ƕ�X��������������¶��壬�����ջ�������ͼʱ��xz��ΪX�������
    plot(xz,10*log10(pow_spec)) %��������ͼ��Y���Ƕ����̶�
    title('ADC Output Spectrum') 
    xlabel('fin(KHz)')
    ylabel('Power (dB)')
    axis([0,0.5*fs/1000,-140,0])
    grid
end
%***************** ��SNDR *****************************************
for i = 1:d_len2         % ���ѭ������������pow_spec�ж�λ�źŷ���������λ��
    if pow_spec(i) > 0.95  %��Ϊ�ǹ�һ�������ף��źŷ����ķ���Ϊ1�����Խ��Ƚϵ���ֵ��Ϊ0.95����
        i_max = i;          %���źŷ�����λ�ø���i_max
    end
end
if add_window == 1
    widm = 15;                   %���������ȣ�����Ŀ��=2*widm+1���������������ڲ�������widm=0����
else
    widm = 0;
end
ps = sum(pow_spec(i_max-widm:i_max+widm));        %���źŷ����Ĺ��ʣ����������ĺ�
SNDR = 10*log10(ps/(sum(pow_spec)-ps));  %��SNDR
%***************** ��SFDR *****************************************
pow_spec(i_max-widm:i_max+widm) = 0;    %���źŷ�����Ϊ0
SFDR = -10*log10(max(pow_spec));   %����SFDR���������Ӳ�������
