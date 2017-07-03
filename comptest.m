addpath('functions', 'plots');
FileName = 'charinfo.mat';
load(['E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L\syncd_b2b_brief\' FileName]);
charComp{1} = charinfo;
load(['E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L\syncd\' FileName]);
charComp{2} = charinfo; clear FileName;
bias = 0.1; deg = 1.2; bits = 4; tech = 'misic'; cur_var = [bias, deg, deg, bits];

eF = {'s', 'w', 'w2', 'rls', 'rls2'}; M = zeros(length(deg),length(bias));
for i=1:length(eF), eF{2,i} = M; end;
mse_char = struct(eF{:}); ber = struct(eF{:}); errors = cell(1,2); clear M i eF;

signal = cell(1,length(charComp)); switched = signal; s_info = signal;
for C = 1:length(charComp)
    signal{C} = syncd_import(charComp{C}, cur_var, tech);
    [switched{C}, s_info{C}] = sw_cycle(signal{C});
    [~,~,~, errors{1,C}] = sw_filter(switched{C}.y_s, switched{C}.xs_slice, s_info{C});
    [~,~,~, errors{2,C}] = sw_filter(switched{C}.Norm.y_s, switched{C}.xs_slice, s_info{C});
end

% for n = 1:s_info{1}.N_cycles
%     if NE < sum([errors{1,1}.s{n}]), NE = sum([errors{1}.s{n}]);
%         cyPlot(signal, switched, s_info, yout, n, errors);
%         waitforbuttonpress;
%     end
% end