%% Comparação entre PISIC, MISIC e step

root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
addpath([root_dir 'MatLab/'], [root_dir 'chav-amo-SOA-prbs'], 'functions', 'plots');
clear root_dir;

SOA = 'CIP-NL';  % SOA used on the measures
bias_range = 0.03:0.005:0.07;
techs = {'step','pisic', 'misic'};

ems_s = zeros(length(techs),length(bias_range));
for Tc = 1:length(techs)
for In = 1:length(bias_range)

if strcmp(techs{Tc},'step')
    imp = 0; tim = 0;
else
    imp = 1.5;
    tim = 0.64;
end;
deg = 1.5;                      % step voltage
cur = bias_range(In);                     % bias current
parameters.var = [tim, imp, deg, cur];
parameters.tech = techs{Tc};      % técnica de pré-impulso e, se for, PRBS
parameters.bitstream = '';      % para PRBS => 'prbs'; para sqrwv => '';

signal = switch_file_import(SOA, parameters);
[switched, s_info] = sw_cycle(signal);
clear tim imp deg cur tech

section = 20;
e = zeros(1,s_info.N_cycles);
for n = 1:s_info.N_cycles
    ys = switched.y_samp{n};    ys = (ys(1:section,2)-s_info.mean)/s_info.mod;
    ys_dd = switched.ys_dd{n};  ys_dd = (ys_dd(1:section,2)-s_info.mean)/s_info.mod;
    e(n) = mean((ys - ys_dd).^2);
end
ems_s(Tc,In) = mean(e);
end
end

%%

bias_range = 2.5*bias_range;

if ishandle(3),close(f); end; f = figure(3); hold on;
set(f,'windowstyle','normal', 'Position', [100, 100, 450, 300])
legs = {'Step', 'PISIC', 'MISIC'};

h1 = plot(bias_range,ems_s(1,:),'.-','linewidth',2,'markersize',10);
h2 = plot(bias_range,ems_s(2,:),'.-','linewidth',2,'markersize',10);
h3 = plot(bias_range,ems_s(3,:),'.-','linewidth',2,'markersize',10);
xlim([min(bias_range) max(bias_range)]);


f1 = fit(bias_range', ems_s(1,:)', 'poly2');
f1p = plot(f1); h1c = get(h1,'color');
set(f1p, 'Color', (h1c+1)/2, 'LineStyle', '--')
f2 = fit(bias_range', ems_s(2,:)', 'poly2');
f2p = plot(f2); h2c = get(h2,'color');
set(f2p, 'Color', (h2c+1)/2, 'LineStyle', '--')
f3 = fit(bias_range', ems_s(3,:)', 'poly2');
f3p = plot(f3); h3c = get(h3,'color');
set(f3p, 'Color', (h3c+1)/2, 'LineStyle', '--')

legend([h1 h2 h3], legs);
xlabel('Bias (A)'), ylabel('Mean Squared Error');
set(gca, 'FontName', 'Times New Roman','FontSize',12)