%% Viewing results

close all; clc;
addpath('functions', 'plots', 'results'); global fignum;
SOA = 'CIP-NL';
% method = {'syncd_b2b_brief', 'misic'};
% method = {'syncd', 'misic'};
bits = 4;
% if strcmp(method{1},'syncd'), bias = 0.06:0.02:0.18;
% elseif strcmp(method{1},'syncd_b2b_brief'), bias = 0.06:0.02:0.16;
% end
bias = 0.06:0.02:0.16;
deg = 0.3:0.3:1.2;

%% UI configuration choice
fiber_c = {'syncd_b2b_brief', 'syncd'};
techs = {'pisic', 'misic'};
choice1 = menu('Characterization', 'Without Fiber', 'With Fiber');
choice2 = menu('Switching Technique', 'PISIC', 'MISIC');
method = {fiber_c{choice1}, techs{choice2}};
%% Load
results_file = sprintf([SOA '_' [method{:}] '-%i.mat'], bits);
load(results_file)
%% Plots
close all;
fignum = 1; fprintf('\nPlotting Section\n');
if length(deg) == 1 && length(bias) > 1, bias_plot(bias, mse_char, 'MSE');
elseif length(deg) > 1, VIplot(bias, deg, mse_char, 'MSE', [0 1]);
    VIplot(bias, deg, ber, 'BER',[-1.5 -.1]);
end