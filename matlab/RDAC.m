function [V_RDAC]=RDAC(Vr,DI,Rarray)
%Vr: Reference voltage
%DI: Digital Input of RDAC. Range is [0,127];
%Rarray: Resistor array of RDAC.
I = Vr/sum(Rarray); %The current flowing through the resistor string
k = int8(DI+1);     
V_RDAC = I*sum(Rarray(1:k));%Calculate output voltage of RDAC
end



