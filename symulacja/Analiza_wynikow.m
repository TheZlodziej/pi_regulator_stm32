clc;
fileName = 'pomiary.json'; % filename in JSON extension 
str = fileread(fileName); % dedicated for reading files as text 
data = jsondecode(str); % Using the jsondecode function to parse JSON from string 

temperature_data = [ data(1).data ];

temp = temperature_data(:, 2);
% t = temperature_data(:, 1);

t = 0:length(temp)-15;
ref = 29*ones(1, length(t));
tplus = 1.01*ref;
tminus = 0.99*ref;

figure;
plot(t, ref, 'color', '[0 0.9 0.9]', 'linewidth', 1)
hold on
plot(t, temp(15:end), 'color', '[.80 0 .9]', 'linewidth', 1);
plot(out.y, 'color', '[0 0 .9]', 'linewidth', 1)
plot(t, tplus, 'k--', t, tminus, 'k--', 'linewidth', 1)
xlim([0 315])
grid on
legend('Zadana', 'Z pomiarow', 'Z symulacji', 'Tunel $1\%$', 'fontsize', 13, 'interpreter', 'latex')
xlabel('$t$ [s]', 'fontsize', 15, 'interpreter', 'latex')
ylabel('$T$ [$^{\circ}$C]', 'interpreter', 'latex', 'fontsize', 15)