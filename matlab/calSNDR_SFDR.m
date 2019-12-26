function [SNDR,SFDR,Offset] = calSNDR_SFDR(adout,d_len,add_window, plot_flag,fs)

%数组adout为所采样的数据，其长度为d_len，则用FFT分析法求功率谱和动态特性的MATLAB程序如下：
%******************** 去直流分量 *************************
% 输出在0~1023之间变化，中间有一个很大的直流分量，在做功率谱分析前，先去掉其直流分量
% 以简化加窗后的动态指标分析
Offset = mean(adout)+0.5;
adout = adout - mean(adout);                                              
%******************** add hanning window *************************
if add_window == 1
    adout = adout.*rot90(hanning(d_len)); % 如果截取的数据长度不是整数个输入信号周期，就要加窗，否则注释掉这一句
end
%******************** FFT变换求功率谱 ****************************
pow_spec = fft(adout).*conj(fft(adout)); %对转换结果用fft求其功率谱
pow_spec = pow_spec/max(pow_spec);   %归一化功率谱
d_len2 = floor(d_len/2);
pow_spec = pow_spec(1:d_len2); %由于功率谱是左右对称的，这里只截取其左半部分
%***************** 画出功率谱 *****************************************
if plot_flag==1
    xz = 0:1/d_len*fs/1000:(d_len2-1)/d_len*fs/1000;     %这里的xz只是对X轴坐标进行了重新定义，在最终画功率谱图时将xz作为X轴的坐标
    plot(xz,10*log10(pow_spec)) %画功率谱图，Y轴是对数刻度
    title('ADC Output Spectrum') 
    xlabel('fin(KHz)')
    ylabel('Power (dB)')
    axis([0,0.5*fs/1000,-140,0])
    grid
end
%***************** 求SNDR *****************************************
for i = 1:d_len2         % 这个循环的作用是在pow_spec中定位信号分量的中心位置
    if pow_spec(i) > 0.95  %因为是归一化功率谱，信号分量的幅度为1，所以将比较的阈值设为0.95即可
        i_max = i;          %将信号分量的位置赋予i_max
    end
end
if add_window == 1
    widm = 15;                   %设置主瓣宽度，主瓣的宽度=2*widm+1，对于整数个周期采样，令widm=0即可
else
    widm = 0;
end
ps = sum(pow_spec(i_max-widm:i_max+widm));        %求信号分量的功率，即主瓣各点的和
SNDR = 10*log10(ps/(sum(pow_spec)-ps));  %求SNDR
%***************** 求SFDR *****************************************
pow_spec(i_max-widm:i_max+widm) = 0;    %将信号分量置为0
SFDR = -10*log10(max(pow_spec));   %现在SFDR就是最大的杂波幅度了
