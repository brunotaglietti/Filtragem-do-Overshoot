close all; clc;
addpath('functions', 'plots'); global fignum;

%% UI Configuration and Memory Allocation
if ~exist('charinfo','var')
    [FileName,PathName, ~] = uigetfile('E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L\');
    load([PathName FileName]); charinfo.Path = PathName; clear FileName PathName;
end
[tech, bits, vars] = char_config(charinfo.cur,charinfo.deg); bias = vars.bias; deg = vars.deg;
eF = {'s', 'w', 'w2', 'rls', 'rls2'}; M = zeros(length(deg),length(bias));
for i=1:length(eF), eF{2,i} = M; end;
mse_char = struct(eF{:}); ber = struct(eF{:}); clear M i eFields;
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
close all; fignum = 1;
if length(deg) == 1 && length(bias) == 1, NE = 0;
errorDistPlot(s_info, errors);
% for n = 1:s_info.N_cycles
%     if NE < sum([errors.s{n}]), NE = sum([errors.s{n}]);
%         cyPlot(signal, switched, s_info, yout, n, errors);
%         waitforbuttonpress;
%     end
% end
elseif length(deg) == 1 && length(bias) > 1, bias_plot(bias, mse_char, 'MSE');
elseif length(deg) > 1, VIplot(bias, deg, mse_char, 'MSE', [0 1]);
    VIplot(bias, deg, ber, 'BER',[-3 -1]);
end
