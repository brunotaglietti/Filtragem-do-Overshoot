addpath('complementary','functions', 'plots');

%% UI Configuration and Memory Allocation
if ~exist('charinfo','var')
    Meas_path = 'C:\Users\btagli\Documents\Unicamp\';
    [FileName,Path, ~] = uigetfile(Meas_path);
    load([Path FileName]); charinfo.root = Path; clear FileName;
end

tech = 'step';
bits = 0;
bias = 0.120;
deg = 1.2;

eF = {'s', 'w', 'w2', 'rls', 'rls2'}; M = zeros(length(deg),length(bias));
for i=1:length(eF), eF{2,i} = M; end
mse_char = struct(eF{:}); ber = struct(eF{:}); errors = cell(1,2); clear M i eF;
%% Processing
t_start = tic;
for B = 1:length(bias)
for V = 1:length(deg)
    cur_var = [bias(B), deg(V), 0, bits];
    signal = soah5import(charinfo,cur_var,tech); % Import
    [switched, s_info] = sw_cycle(signal); % Cycle cropping
    [yout, mse_char(V,B), ber(V,B), errors] = sw_filter(switched.y_s, switched.xs_slice, s_info);
    toc(t_start);
end
end

%% PLOTS
% close all;
if length(deg) == 1 && length(bias) == 1, NE = zeros(s_info.N_cycles,1);
%     errorDistPlot(s_info, errors);
    for n = 1:s_info.N_cycles
        if length(errors)>1, cE = errors{1}; else, cE = errors; end
        NE(n) = sum(cE.s{n}(1+5:end-5)) - sum(cE.w{n}(1+5:end-5));
        cyPlot(signal, switched, s_info, yout, n, cE);
        waitforbuttonpress;
        close all;
    end
%     [~,n] = max(NE); cyPlot(signal, switched, s_info, yout, n, cE);
elseif length(deg) == 1 && length(bias) > 1, bias_plot(bias, mse_char, 'MSE');
elseif length(deg) > 1, VIplot(bias, deg, mse_char, 'MSE');
    VIplot(bias, deg, ber, 'BER');
end