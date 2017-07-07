addpath('functions', 'plots');

% tech = {'pisic', 'misic'};
tech = {'pisic'};
%% UI Configuration and Memory Allocation
if ~exist('charinfo','var')
    [FileName,Path, ~] = uigetfile('E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L\');
    load([Path FileName]); clear FileName;
end
bits = 8; bias = 0.1; deg = 1.2;
eF = {'s', 'w', 'w2', 'rls', 'rls2'}; M = zeros(length(deg),length(bias));
for i=1:length(eF), eF{2,i} = M; end;
mse_char = struct(eF{:}); ber = struct(eF{:}); errors = cell(1,2); clear M i eF;

%%
tStart = tic;
cur_var = [bias, deg, deg, bits];
for k = 1:length(tech)
    signal  = syncd_import(charinfo, cur_var, tech{k});
    [switched, s_info] = sw_cycle(signal);
    [yout, mse, ber, errors{k}] = sw_filter(switched.y_s, switched.xs_slice, s_info);
    [~, ~, ~, errors{2}] = sw_filter(switched.Norm.y_s, switched.xs_slice, s_info);
    errorDistPlot(s_info, errors, tech{k});
    toc(tStart);
end