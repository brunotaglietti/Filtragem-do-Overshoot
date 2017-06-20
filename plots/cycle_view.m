% Visualização de um ciclo do sinal
% Script complementar ao "Overshoot_filter_4.m"

clc; close all; clear all;
root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
addpath([root_dir 'MatLab/'], [root_dir 'chav-amo-SOA-prbs'], 'functions', 'plots');
clear root_dir;
% set(0,'DefaultFigureWindowStyle','docked')

%% Leitura da Medição

SOA = 'CIP-NL';  % SOA used on the measures

tim = 0.64;                     % pre-impulse duration (ns) / pisic 4 => 0.32

imp = 1.00;                      % pre-impulse voltage
deg = 1.25;                      % step voltage
cur = 0.055;                     % bias current
cycle = 75;

% imp = 0.5;
% deg = 0.5;
% cur = 0.030;
% cycle = 74;

parameters.var = [tim, imp, deg, cur];
parameters.tech = 'misic';      % técnica de pré-impulso e, se for, PRBS
parameters.bitstream = '';      % para PRBS => 'prbs'; para sqrwv => '';

signal = switch_file_import(SOA, parameters);
[switched, s_info] = sw_cycle(signal);

clear tim imp deg cur tech

%%
close all
if exist('pulselength','var') == 0, pulselength = 8e-9; end;
fs = 1/(signal.t(2)-signal.t(1));
samples = round(pulselength*2*fs);

yf = signal.yf;     y_unb = signal.y_unb;   t = signal.t;
y_avg = zeros(samples,1);
N_cycles = floor(length(signal.y) / samples);
for n = 1:N_cycles, range = (n - 1)*samples + 1 : samples*n;
    y_avg = y_avg + signal.y(range); end
y_avg = y_avg / N_cycles;
y_avg = [y_avg; y_avg];

rise_thresh = (max(y_avg) - min(y_avg)) / 10*6 + min(y_avg);   % 70% da subida (em y)
fall_thresh = (max(y_avg) - min(y_avg)) / 10*3 + min(y_avg);   % 30% da subida

if(y_avg(samples)<rise_thresh)     % Condição de chave aberta no ponto _samples_.
    riseedge = find(y_avg>rise_thresh,1,'first');
    falledge = find(y_avg(riseedge:end)<fall_thresh,1,'first') + riseedge;
elseif(y_avg(round(samples))>fall_thresh)    % Condição de chave fechada no ponto _samples_.
    falledge = find(y_avg<fall_thresh,1,'first');
    riseedge = find(y_avg(falledge:end)>rise_thresh,1,'first') + falledge;
end

riseedge = riseedge + (cycle + 1)*samples; falledge = falledge + (cycle + 1)*samples;
range = riseedge-round(samples/15) : falledge + round(samples/15);
y = switched.y{cycle}; ys = switched.y_s{cycle}; ys_dd = switched.ys_slice{cycle};

%%

fig1 = figure(1);
set(gca, 'FontName', 'Times New Roman','FontSize',12)
plot(signal.t(range),signal.y(range),'Color',.9*ones(1,3)), hold on
clear xlim, xlim(signal.t([min(range), max(range)]))

plot(y(:,1),y(:,2),'color',.4*ones(1,3))
plot(y(ys(1:end-2,3),1), ys(1:end-2,2),'k.')
x_axis=get(gca,'xlim');
plot(x_axis, s_info.y_mean*[1 1],'--','color',.9*ones(1,3))
plot(x_axis, s_info.y_mean - s_info.y_mod*[1 1],'--','color',.9*ones(1,3))
plot(x_axis, s_info.y_mean + s_info.y_mod*[1 1],'--','color',.9*ones(1,3))
plot(y(ys(1:end-2,3),1), ys_dd(1:end-2,2),'.','color',.9*ones(1,3))
xlabel('Time (s)'), ylabel('Step (V)')

%%
M = 2;
section = 20;
section_rls = 5;

Rx = zeros(s_info.N_cycles,M); Pxd = Rx; Rrls = Rx; Prls = Rx;
for n = 1:s_info.N_cycles
    ys = switched.y_s{n}; ys = (ys(:,2)-s_info.y_mean)/s_info.y_mod;
    ys_dd = switched.ys_slice{n}; ys_dd = (ys_dd(:,2)-s_info.y_mean)/s_info.y_mod;
    if section > length(ys), section = length(ys); end;
    
    R = mXcor(ys(1:section), M);
    Rx(n,:) = R(1,:);
    Pxd(n,:) = mXcor(ys(1:section), ys_dd(1:section), M);
    
    Rrls_c = mXcor(ys(1:section_rls),M); Rrls(n,:) = Rrls_c(1,:);
    Prls(n,:) = mXcor(ys(1:section_rls), ys_dd(1:section_rls), M);
end
Rx = mean(Rx); Pxd = mean(Pxd);
w = toeplitz(Rx)\Pxd';
yw = zeros(s_info.N_cycles,section); yrls = yw;

e = cell(s_info.N_cycles,1);   ew = e;     erls = e;
wrls = zeros(M,1);
Rrls = mean(Rrls); Prls = mean(Prls); wrlsi = toeplitz(Rrls)\Prls';
Prls = inv(toeplitz(Rrls));
for n = 1:s_info.N_cycles
    ys = switched.y_s{n};    ys = (ys(1:section,2)-s_info.y_mean)/s_info.y_mod;
    ys_dd = switched.ys_slice{n};  ys_dd = (ys_dd(1:section,2)-s_info.y_mean)/s_info.y_mod;
    
    yw(n,:) = filter(w,1,ys);
    [w_rls, ~, yrls(n,:)] = algRLS_mod(ys,ys_dd,wrlsi,Prls); wrls = w_rls(:,end);
    
    ew{n} = (yw(n,:) - ys_dd').^2;
    e{n} = (ys - ys_dd).^2;
    erls{n} = (yrls(n,:) - ys_dd').^2;
end

%%
close all
riseedge = riseedge + (cycle + 1)*samples; falledge = falledge + (cycle + 1)*samples;
range = riseedge-round(samples/15) : falledge + round(samples/15);
y = switched.y{cycle}; ys = switched.y_s{cycle}; ys_dd = switched.ys_slice{cycle};
e_c = e{cycle};   ew_c = ew{cycle}; erls_c = erls{cycle};
y_sec(:,2) = (y(:,2) - s_info.y_mean)/s_info.y_mod;
ys_sec(:,2) = (ys(:,2) - s_info.y_mean)/s_info.y_mod;
dd = (ys_dd(:,2) - s_info.y_mean)/s_info.y_mod;
t_s = 1e6*y(ys(1:section,3),1);

fig2 = figure(2);
set(fig2,'windowstyle','normal', 'Position', [100, 100, 450, 450])
subplot(3,1,[1, 2]);

plot(1e6*y(1:ys(section,3),1), y_sec(1:ys(section,3),2),'color',.6*ones(1,3)); hold on
h1 = plot(t_s, ys_sec(1:section,2),'.', 'color', .4*ones(1,3), 'markersize', 14);
x_axis = get(gca, 'xlim');
plot(x_axis, [1 1], '--', x_axis, -[1 1], '--', x_axis, [0 0], '--', 'color', .9*ones(1,3))
plot(t_s, (ys_dd(1:section,2)-s_info.y_mean)/s_info.y_mod,...
    '.', 'color', .6*[1 1 1], 'MarkerSize', 10);
h2 = plot(t_s, yrls(cycle,:),...
    'x', 'Color', [71 203 44]/255, 'linewidth', 2, 'markersize', 10);
h3 = plot(t_s, yw(cycle,:),...
    '+', 'Color', [72, 133, 237]/255, 'linewidth', 2, 'markersize', 10); drawnow;
xlim([min(t_s) max(t_s)]); ylim([min(y_sec(1:ys(section,3),2)), max(y_sec(1:ys(section,3),2))]);
xlabel('Time (µs)');
legend([h1 h2 h3], 'Original samples', 'RLS', 'Wiener filter'); ylabel('Signals');
set(gca, 'FontName', 'Times New Roman','FontSize',12);

subplot 313; hold on;
fig_prop = {'linewidth', 2, 'markersize', 10};
h1 = plot(t_s, e_c(1:section), '.-', 'color', .4*ones(1,3), fig_prop{:});
h2 = plot(t_s, erls_c(1:section), 'x-', 'Color', [71 203 44]/255, fig_prop{:});
h3 = plot(t_s, ew_c(1:section), '+-', 'Color', [72, 133, 237]/255, fig_prop{:}); drawnow;
xlim([min(t_s) max(t_s)]);
% ylim([0 max([e_c; erls_c'; ew_c';])]);
% ylim([0 3.5]);
ylim([0 1])
ylabel('e^2');   xlabel('Time (µs)');    title(' ');
set(gca, 'FontName', 'Times New Roman','FontSize',12);