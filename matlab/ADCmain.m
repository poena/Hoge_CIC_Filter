%SAR ADC with weight redundancy
%SAR ADC with non-ideal effect
%1)capacitor/resistor mismatch
%2)comparator offset
%3)comparator equivalent input noise
%4)input parasitic capacitor of the comparator
clc;
clear all;


d_len = 2^15;           %确定总的采样长度
fs = 200e3;             %sampling rate
fin = 163*fs/d_len;      %input frequency
adout(d_len) = 0;       %定义存放转换结果的数组,decimal
adoutB=zeros(d_len,18); %定义存放转换结果的数组,binary，LSB,...,MSB

delComos = 0.000;       %比较器失调均方根值,V
del_Comvn = 35e-6;       %比较器等效输入噪声,V

Cval=28e-15;            %单位电容大小
del_C=Cval*0.000;      %电容误差随机分布标准差
Cp1 = 700e-15;          %采样网络电容的上极板的寄生电容大小
Cp2 = 350e-15;          %DAC网络电容的上极板的寄生电容大小
Ru = 437;               %RDAC网络单位电阻大小
del_R=Ru*0.000;         %电阻误差随机分布标准差
Vr=5;                   %参考电压大小
Vdd=5;
Vcms=Vdd/2;             %采样网络上极板共模
Vcmi=Vdd/2;             %DAC网络上极板共模


%***********给比较器加上失调**************
Com_os = delComos*randn(1,1); %比较器失调 
%******给电容加上随机失配****************%
Cup(1:23) = 0;
Cdn(1:23) = 0;
Csp = 0;
Csn = 0;
Rarray(1:129) = 0;

for i=1:1
    Cup(1) = Cup(1) + Cval+del_C*randn(1,1);%C_RDAC
    Cup(2) = Cup(2) + Cval+del_C*randn(1,1);%C_fixed
    Cup(3) = Cup(3) + Cval+del_C*randn(1,1);%C7
    Cup(4) = Cup(4) + Cval+del_C*randn(1,1);%C8n
    Cup(5) = Cup(5) + Cval+del_C*randn(1,1);%C8p
    Cup(6) = Cup(6) + Cval+del_C*randn(1,1);%C9n
    Cup(7) = Cup(7) + Cval+del_C*randn(1,1);%C9p
    
    Cdn(1) = Cdn(1) + Cval+del_C*randn(1,1);
    Cdn(2) = Cdn(2) + Cval+del_C*randn(1,1);
    Cdn(3) = Cdn(3) + Cval+del_C*randn(1,1);
    Cdn(4) = Cdn(4) + Cval+del_C*randn(1,1);
    Cdn(5) = Cdn(5) + Cval+del_C*randn(1,1);
    Cdn(6) = Cdn(6) + Cval+del_C*randn(1,1);
    Cdn(7) = Cdn(7) + Cval+del_C*randn(1,1);
end
for i=1:2
    Cup(8) = Cup(7) + Cval+del_C*randn(1,1);%C10n=2C
    Cup(9) = Cup(7) + Cval+del_C*randn(1,1);%C10p=2C
        
    Cdn(8) = Cdn(7) + Cval+del_C*randn(1,1);
    Cdn(9) = Cdn(7) + Cval+del_C*randn(1,1);
end
for i=1:4
    Cup(10) = Cup(10) + Cval+del_C*randn(1,1);%C11n=4C
    Cup(11) = Cup(11) + Cval+del_C*randn(1,1);%C11p=4C
    
    Cdn(10) = Cdn(10) + Cval+del_C*randn(1,1);
    Cdn(11) = Cdn(11) + Cval+del_C*randn(1,1);
end
for i=1:5
    Cup(12) = Cup(12) + Cval+del_C*randn(1,1);%C12n=5C
    Cup(13) = Cup(13) + Cval+del_C*randn(1,1);%C12p=5C
    
    Cdn(12) = Cdn(12) + Cval+del_C*randn(1,1);
    Cdn(13) = Cdn(13) + Cval+del_C*randn(1,1);
end
for i=1:10
    Cup(14) = Cup(14) + Cval+del_C*randn(1,1);%C13n=10C
    Cup(15) = Cup(15) + Cval+del_C*randn(1,1);%C13p=10C
    
    Cdn(14) = Cdn(14) + Cval+del_C*randn(1,1);
    Cdn(15) = Cdn(15) + Cval+del_C*randn(1,1);
end
for i=1:18
    Cup(16) = Cup(16) + Cval+del_C*randn(1,1);%C14n=18C
    Cup(17) = Cup(17) + Cval+del_C*randn(1,1);%C14p=18C
    
    Cdn(16) = Cdn(16) + Cval+del_C*randn(1,1);
    Cdn(17) = Cdn(17) + Cval+del_C*randn(1,1);
end
for i=1:32
    Cup(18) = Cup(18) + Cval+del_C*randn(1,1);%C15n=32C
    Cup(19) = Cup(19) + Cval+del_C*randn(1,1);%C15p=32C
    
    Cdn(18) = Cdn(18) + Cval+del_C*randn(1,1);
    Cdn(19) = Cdn(19) + Cval+del_C*randn(1,1);
end
for i=1:62
    Cup(20) = Cup(20) + Cval+del_C*randn(1,1);%C16n=62C
    Cup(21) = Cup(21) + Cval+del_C*randn(1,1);%C16p=62C
    
    Cdn(20) = Cdn(20) + Cval+del_C*randn(1,1);
    Cdn(21) = Cdn(21) + Cval+del_C*randn(1,1);
end
for i=1:120
    Cup(22) = Cup(22) + Cval+del_C*randn(1,1);%C17n=120C
    Cup(23) = Cup(23) + Cval+del_C*randn(1,1);%C17p=120C
    
    Cdn(22) = Cdn(22) + Cval+del_C*randn(1,1);
    Cdn(23) = Cdn(23) + Cval+del_C*randn(1,1);
end
for i=1:1024
    Csp = Csp + Cval+del_C*randn(1,1);  %Csp=1024C
    Csn = Csn + Cval+del_C*randn(1,1);  %Csn=1024C
end
for i=1:129
    if i==1 || i==129   %第1个和第129个电阻为Ru/2
        R1 = Ru + del_R*randn(1,1);
        R2 = Ru + del_R*randn(1,1);
        Rarray(i) = R1*R2/(R1+R2);
    else
        Rarray(i) = Ru + del_R*randn(1,1); %第2到128个电阻为Ru
    end
end

weight_err(1:18)=[0,0,0,0,0,0,0,(Cup(3)-Cval)*128,(Cup(4)-Cval)*256,(Cup(6)-Cval)*256,...
    (Cup(8)-2*Cval)*256,(Cup(10)-4*Cval)*256,(Cup(12)-5*Cval)*256,(Cup(14)-10*Cval)*256,...
    (Cup(16)-18*Cval)*256,(Cup(18)-32*Cval)*256,(Cup(20)-62*Cval)*256,(Cup(22)-120*Cval)*256];

%*******************SAR ADC Begin**********************************%
for k = 1:d_len                      
    Vip = Vr/2+0.95*Vr/2*sin(k*2*pi*fin/fs);  % 输入单频信号，幅度近似满量程，用sar adc对其进行转换，并将转换结果放到数组adout中
    Vin = 0;
    [adout(k),adoutB(k,:)]=SAR_ADC(Vip,Vin,Cup,Cup,Csp,Csp,Cp1,Cp2,Rarray,Vcmi,Vcms,Vr,Com_os,del_Comvn);
end
adout_signed = adout-32768;
%*******************SAR ADC End**********************************%

%plot(adout);
plot_flag = 1;
add_window = 0;
[SNDR,SFDR,Offset] = calSNDR_SFDR(adout_signed,d_len,add_window,plot_flag,fs) %调用计算SNDR,SFDR,offset的程序





