addpath('functions', 'plots');

%% UI Configuration and Memory Allocation
if ~exist('charinfo','var')
    [FileName,Path, ~] = uigetfile('E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L\');
    load([Path FileName]); clear FileName;
end
[tech, bits, vars] = char_config(charinfo.cur,charinfo.deg); bias = vars.bias; deg = vars.deg;
eF = {'s', 'w', 'w2', 'rls', 'rls2'}; M = zeros(length(deg),length(bias));
for i=1:length(eF), eF{2,i} = M; end;
mse_char = struct(eF{:}); ber = struct(eF{:}); errors = cell(1,2); clear M i eF;
%% Processing
t_start = tic;
for B = 1:length(bias)
for V = 1:length(deg)
    cur_var = [bias(B), deg(V), deg(V), bits];
    signal = soah5import(charinfo,cur_var,tech); % Import
    [switched, s_info] = sw_cycle(signal); % Cycle cropping
    [yout, mse_char(V,B), ber(V,B), errors{1}] = sw_filter(switched.y_s, switched.xs_slice, s_info);
    [~, ~, ~, errors{2}] = sw_filter(switched.Norm.y_s, switched.xs_slice, s_info);
    toc(t_start);
end
end

%% PLOTS
% close all;
if length(deg) == 1 && length(bias) == 1, NE = zeros(s_info.N_cycles,1);
    errorDistPlot(s_info, errors);
    for n = 1:s_info.N_cycles
        NE(n) = sum(errors{1}.s{n}(1+5:end-5)) - sum(errors{1}.w{n}(1+5:end-5));
    end
    [~,n] = max(NE); cyPlot(signal, switched, s_info, yout, n, errors);
elseif length(deg) == 1 && length(bias) > 1, bias_plot(bias, mse_char, 'MSE');
elseif length(deg) > 1, VIplot(bias, deg, mse_char, 'MSE');
    VIplot(bias, deg, ber, 'BER');
end