close all; clc;
addpath('functions', 'plots'); global fignum;

%% UI Configuration and Memory Allocation
if ~exist('charinfo','var')
    [FileName,PathName, ~] = uigetfile('E:\Projetos Colaborativos\chav-amo-SOA-prbs');
    load([PathName FileName]); charinfo.Path = PathName; clear FileName PathName;
end
[tech, bits, vars] = char_config(charinfo.cur,charinfo.deg); bias = vars.bias; deg = vars.deg;
M = zeros(length(deg),length(bias));
mse_char = struct('s', M, 'w', M, 'w2', M, 'rls', M, 'rls_i', M, 'rls2', M);
ber =   struct('s', M, 'w', M, 'w2', M, 'rls', M, 'rls_i', M, 'rls2', M); clear M;

%% Processing
t_start = tic;
for B = 1:length(bias)
for V = 1:length(deg)
cur_var = [bias(B), deg(V), deg(V), bits];
signal = syncd_import(charinfo,cur_var,tech); % Import
[switched, s_info] = sw_cycle(signal); % Cycle cropping
[yout, mse_char(V,B), ber(V,B), errors] = sw_filter(switched, s_info); % Filtering
toc(t_start);
end
end

%% PLOTS
close all; fignum = 1; fprintf('\nPlotting Section\n');
if length(deg) == 1 && length(bias) == 1, NE = 0;
for n = 1:s_info.N_cycles
    if NE < sum(errors.s(n,:)), NE = sum(errors.s(n,:));
        close all; fignum = 1; cyPlot(signal, switched, s_info, yout, n, errors);
        waitforbuttonpress;
    end
end
elseif length(deg) == 1 && length(bias) > 1, bias_plot(bias, mse_char, 'MSE');
elseif length(deg) > 1, VIplot(bias, deg, mse_char, 'MSE', [0 1]);
    VIplot(bias, deg, ber, 'BER',[-1.5 -.1]);
end
