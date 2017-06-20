%% Comparação entre PISIC, MISIC e step

root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
addpath([root_dir 'MatLab/'], [root_dir 'chav-amo-SOA-prbs'], 'functions', 'plots');
clear root_dir;

SOA = 'CIP-NL';  % SOA used on the measures
bias_range = 0.03:0.005:0.07;
tim_range = [0 .16 .32 .64];

ems_w = zeros(length(tim_range),length(bias_range));

%% Characterization
for tn = 1:length(tim_range)
for In = 1:length(bias_range)

if tim_range(tn) == 0, imp = 0; parameters.tech = 'step';
else, imp = 1.5; parameters.tech = 'misic'; end;

tim = tim_range(tn);
deg = 1.5;                      % step voltage
cur = bias_range(In);                     % bias current
parameters.var = [tim, imp, deg, cur];
% parameters.tech = 'misic';      % técnica de pré-impulso e, se for, PRBS
parameters.bitstream = '';      % para PRBS => 'prbs'; para sqrwv => '';

signal = switch_file_import(SOA, parameters);
[switched, s_info] = sw_cycle(signal);
clear tim imp deg cur tech

%% Filtering
M = 2;
section = 20;

Rx = zeros(s_info.N_cycles,M); Pxd = Rx;
for n = 1:s_info.N_cycles
    ys = switched.y_samp{n}; ys = (ys(:,2)-s_info.mean)/s_info.mod;
    ys_dd = switched.ys_dd{n}; ys_dd = (ys_dd(:,2)-s_info.mean)/s_info.mod;
    if section > length(ys), section = length(ys); end;
    R = mXcor(ys(1:section), M);
    Rx(n,:) = R(1,:);
    Pxd(n,:) = mXcor(ys(1:section), ys_dd(1:section), M);
end
Rx = mean(Rx); Pxd = mean(Pxd);
w = toeplitz(Rx)\Pxd';
yw = zeros(s_info.N_cycles,section); yrls = yw;
ew = zeros(s_info.N_cycles,1);
for n = 1:s_info.N_cycles
    ys = switched.y_samp{n};    ys = (ys(1:section,2)-s_info.mean)/s_info.mod;
    ys_dd = switched.ys_dd{n};  ys_dd = (ys_dd(1:section,2)-s_info.mean)/s_info.mod;
    yw(n,:) = filter(w,1,ys);
    ew(n) = mean((yw(n,:) - ys_dd').^2);
end
ems_w(tn,In) = mean(ew);

clear ys R ys_dd Rx Pxd e ew e_rls erls w w_rls wrls n

end
end

%%
bias_range = 2.5*bias_range;
% set(0,'DefaultFigureWindowStyle','docked')
% colors = [71 203 44; 44 71 203; 203 44 71]/255;
colors = zeros(length(tim_range),3);
fig_prop = {'.-','linewidth',2,'markersize',10};
if ishandle(2), close(f2); end; f2 = figure(2); hold on;
set(f2,'windowstyle','normal', 'Position', [100, 100, 450, 300])
h1 = plot(bias_range,ems_w(1,:),fig_prop{:});
h2 = plot(bias_range,ems_w(2,:),fig_prop{:});
h3 = plot(bias_range,ems_w(3,:),fig_prop{:});
h4 = plot(bias_range,ems_w(4,:),fig_prop{:});

colors(1,:) = get(h1,'color');
colors(2,:) = get(h2,'color');
colors(3,:) = get(h3,'color');
colors(4,:) = get(h4,'color');

fit1 = fit(bias_range', ems_w(1,:)', 'poly2');
f1p = plot(fit1); set(f1p, 'Color', (colors(1,:)+1)/2, 'LineStyle', '--')
fit2 = fit(bias_range', ems_w(2,:)', 'poly2');
f2p = plot(fit2); set(f2p, 'Color', (colors(2,:)+1)/2, 'LineStyle', '--')
fit3 = fit(bias_range', ems_w(3,:)', 'poly2');
f3p = plot(fit3); set(f3p, 'Color', (colors(3,:)+1)/2, 'LineStyle', '--')
fit4 = fit(bias_range', ems_w(4,:)', 'poly2');
f4p = plot(fit4); set(f4p, 'Color', (colors(4,:)+1)/2, 'LineStyle', '--')

set(gca, 'FontName', 'Times New Roman','FontSize',12)
xlabel('Bias (A)'), ylabel('Mean Squared Error');
clear xlim, xlim([min(bias_range) max(bias_range)])
legs = {'Step', 'MISIC-2', 'MISIC-4', 'MISIC-8'};
legend(legs);