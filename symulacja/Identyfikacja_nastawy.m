clear all; close all; clc

Temp =  load('pomiary_nowe.csv');
t = 1:length(Temp);
c = Temp(1);
dT = Temp - c;

k = dT(end);

for i = 1:length(t)
   if dT(i)>0.6315*dT(end) && dT(i)<0.6325*dT(end)
       T = t(i); 
   end
end

s = tf('s');
G = k/(s*T+1);

tm = 0:length(t)-1;
uu = ones(1, length(tm));
ym = lsim(G, uu, tm);

figure
plot(t, dT, 'linewidth', 1.5)
hold on
plot(tm, ym, 'k', 'linewidth', 1.5)
xlim([0 length(Temp)])
ylim([0 8])
grid on
legend('Z pomiarow', '$G(s) = \frac{7.4}{1+289s}$' ,'fontsize', 15, 'interpreter', 'latex')
xlabel('$t$ [s]','interpreter', 'latex', 'fontsize', 15)
ylabel('$T$ [$^{\circ}$C]', 'interpreter', 'latex', 'fontsize', 15)

Tp = 1;

%parametry projektowe
kappa = 5; %maksymalne przeregulowanie
ksi = -log(kappa/100)/sqrt(pi^2+log(kappa/100)^2); %wynikowy wspolczynnik tlumienia

alpha = 0.01; %zadany tunel dla czasu regulacji
Tr = 200; %zadany czas regulacji do tunelu alpha

wn = 1/ksi/Tr*log(1/alpha/sqrt(1-ksi^2)); %pulsacja drgan wlasnych na podstawie projektowanego czasu regulacji


poly_proj = [1 2*ksi*wn wn^2]; %wielomian charakterystyczny transmitancji projektowej

%obliczane nastawy regulatora z przyrownania wspolczynnikow wielomianow
Kp = (poly_proj(2)*T - 1)/k  
Ti = k*Kp/wn^2/T
