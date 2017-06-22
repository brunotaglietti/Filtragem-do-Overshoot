close all; clc;
addpath('functions', 'plots'); global fignum;

%% UI configuration

SOA = 'CIP-NL';
bias = 0.06:0.02:0.16;  deg = 0.3:0.3:1.2;
[method, bits, vars] = char_config(bias,deg); bias = vars.bias; deg = vars.deg;

M = zeros(length(deg),length(bias));
mse_char = struct('s', M, 'w', M, 'w2', M, 'rls', M, 'rls_i', M, 'rls2', M);
ber =   struct('s', M, 'w', M, 'w2', M, 'rls', M, 'rls_i', M, 'rls2', M);

%% Processing
t_start = tic;
for B = 1:length(bias)
for V = 1:length(deg)
char_var = [bias(B), deg(V), deg(V), bits];
signal = syncd_import(SOA,char_var,method); % Import
[switched, s_info] = sw_cycle(signal); % Cycle cropping
[yout, mse_char(V,B), ber(V,B), errors] = sw_filter(switched, s_info); % Filtering
toc(t_start);
end
end

%% PLOTS
close all; fignum = 1; fprintf('\nPlotting Section\n');
if length(deg) == 1 && length(bias) == 1, cyPlot(signal,switched, s_info, yout, 7000, errors);
elseif length(deg) == 1 && length(bias) > 1, bias_plot(bias, mse_char, 'MSE');
elseif length(deg) > 1, VIplot(bias, deg, mse_char, 'MSE', [0 1]);
    VIplot(bias, deg, ber, 'BER',[-1.5 -.1]);
end
% %% Errors checking
% NE = 0;
% for n = 1:s_info.N_cycles
%     if NE < sum(errors.s(n,:)), NE = sum(errors.s(n,:));
%         close all; fignum = 1;
%         cyPlot(signal, switched, s_info, yout, n, errors);
%         waitforbuttonpress;
%     end
% end
% 
% %% Saving Results
% results_file = ['./results/' SOA '_' method{:} sprintf('-%i',bits) '.mat'];
% save(results_file, 'yout', 'mse_char', 'ber', 'errors');
% end
% end
% load handel; sound(y, Fs);