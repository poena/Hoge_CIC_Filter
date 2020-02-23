clear;

R = 2;
% system bode function
%sys = tf([-1.376e10],[1,2.933e5,3.059e10]);
%[mag,phase,wout] = bode(sys,w);
%magdb = 20*log10(reshape(mag(1,1,:),1,len));

%f=logspace(-2,8,90001);
f=logspace(2,7,60001);
w = 2*pi*f;
len = size(f,2);
%bode(sys,w)

H1 = (-1.376e10)./((w*1i).^2 + 2.933e5*(w*1i) + 3.059e10);
abH1 = abs(H1);
magdb1 = 20*log10(abH1);

%R = 16;
M = 1;
N = 1;
Fs = 200000;
H2 = abs((sin((R*M/Fs/2)*w)./(R*M * sin(w./(Fs*2))))).^N;
abH2 = abs(H2);
magdb2 = 20*log10(abH2);

H = H1.*H2;
abH = abs(H);
magdball = 20*log10(abH);

figure;
semilogx(f,magdball(:))
xlabel('Frequency(Hz)')
ylabel('Attitude(db)')
legend(['OS by ', sprintf('%d',R)])
ylim([-100 0])
grid on
