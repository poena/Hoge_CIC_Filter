
R = 2;
M = 1;
N = 1;
fprintf('R=%d, M=%d, N = %d',R, M, N);

Fs = 200000;
Fmax = 1e6;
w = [1e-5:1/1000:Fmax/Fs];
f = w.* Fs;
  
H = abs((sin(R*M*pi*w)./(R*M * sin(pi * w)))).^N;
Hdb = 10 * log(H);

kstr = ['R=',int2str(R),'M=', int2str(M), 'N =', int2str(N)];
plot(f, Hdb);
title(kstr);
%legend(kstr);
grid();
xlim([100, 1e6]);
ylim([-90, 0]);
xlabel('Sampling Rate [Hz]');
ylabel('Attenuation [dB]');
set(gca,'XScale','log');






