function [dout,adoutB]=SAR_ADC(Vip,Vin,Cup,Cdn,Csp,Csn,Cp1,Cp2,Rarray,Vcmi,Vcms,Vr,Com_os,del_Comvn)
DI_RDAC=64;  %RDAC��ʼ������
VRDAC_P = RDAC(Vr,DI_RDAC,Rarray);    %RDAC���˳�ʼ�����ѹ
VRDAC_N = RDAC(Vr,127-DI_RDAC,Rarray);%RDAC���˳�ʼ�����ѹ
Vcmx = (Vip+Vin)/2-Vcms+Vcmi;  %�������紦�ڽ�����ʱ�¼���˵Ĺ�ģ��ѹ
%�Ƚ����������˲���˲��������
Qp = (Vcms-Vip)*Csp+Vcms*Cp1+(Vcmi-VRDAC_P)*Cup(1)+Vcmi*sum(Cup(2:23))+Vcmi*Cp2;      
%�Ƚ������븺�˲���˲��������
Qn = (Vcms-Vin)*Csn+Vcms*Cp1+(Vcmi-VRDAC_N)*Cdn(1)+(Vcmi-Vr)*sum(Cdn(2:23))+Vcmi*Cp2; 
%Qn = (Vcms-Vin)*Csn+(Vcmi-Vr/2)*Cdn(1)+Vcmi*sum(Cup(2:23))-Vr*sum(Cdn(3:23));
Ctotp=sum(Cup)+Csp+Cp1+Cp2;
Ctotn=sum(Cdn)+Csn+Cp1+Cp2;
Vop(1:19)=0;
Von(1:19)=0;
%��һ�αȽ�ʱ�Ƚ�������˵ĵ�ѹ
Vop(1)= (Qp+Vcmx*Csp+VRDAC_P*Cup(1)+Vr*(Cup(3)+Cup(5)+Cup(7)+Cup(9)+Cup(11)...
       +Cup(13)+Cup(15)+Cup(17)+Cup(19)+Cup(21)+Cup(23)))/Ctotp;
Von(1)= (Qn+Vcmx*Csn+VRDAC_N*Cdn(1)+Vr*(Cdn(3)+Cdn(5)+Cdn(7)+Cdn(9)+Cdn(11)...
       +Cdn(13)+Cdn(15)+Cdn(17)+Cdn(19)+Cdn(21)+Cdn(23)))/Ctotn;  
B(1:18)=0;      %Binary output, MSB,...,LSB
adoutB(1:18)=0; %Binary output, LSB,...,MSB

for i=1:18  %��αȽ�18��
    Vo = Vop(i)-Von(i)+Com_os+del_Comvn*randn(1,1);
    if i < 11            %��10bit�Ƚϣ�bit17-bit8
        if Vo > 0
            Vop(i+1) = Vop(i) - Vr*Cup(18-2*i+7)/Ctotp;
            Von(i+1) = Von(i) + Vr*Cdn(18-2*i+6)/Ctotn;
            B(i)=0;
        else
            Vop(i+1) = Vop(i) + Vr*Cup(18-2*i+6)/Ctotp;
            Von(i+1) = Von(i) - Vr*Cdn(18-2*i+7)/Ctotn;
            B(i)=1;
        end
    elseif i==11       %bit7�Ƚ�
        if Vo > 0
            Vop(i+1) = Vop(i) - Vr*Cup(18-2*i+7)/Ctotp;
            Von(i+1) = Von(i);
            B(i)=0;
        else
            Vop(i+1) = Vop(i);
            Von(i+1) = Von(i) - Vr*Cdn(18-2*i+7)/Ctotp;
            B(i)=1;
        end
    else             %��7bit�Ƚϣ�bit6-bit0,����RDAC
        if Vo > 0
            DI_RDAC = DI_RDAC-128/2^(i-10);
            B(i)=0;
        else
            DI_RDAC = DI_RDAC+128/2^(i-10);
            B(i)=1;
        end
        Vop(i+1) = Vop(i)-(VRDAC_P-RDAC(Vr,DI_RDAC,Rarray))*Cup(1)/Ctotp;
        Von(i+1) = Von(i)-(VRDAC_N-RDAC(Vr,127-DI_RDAC,Rarray))*Cdn(1)/Ctotn;
        VRDAC_P = RDAC(Vr,DI_RDAC,Rarray);
        VRDAC_N = RDAC(Vr,127-DI_RDAC,Rarray);
    end
    adoutB(19-i)=B(i);
end

Weight = [30720,15872,8192,4608,2560,1280,1024,512,256,256,128,64,32,16,8,4,2,1];
dout = B*Weight'; %decimal output