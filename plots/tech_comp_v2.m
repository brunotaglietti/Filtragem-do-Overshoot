rootdir = 'E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L\';
addpath('functions', 'plots');

%% UI Configuration and Memory Allocation
% if ~exist('charinfo','var')
%     [FileName,Path, ~] = uigetfile(rootdir); load([Path FileName]); clear FileName;
% end

for bias = [0.08 0.1 0.12]
deg = 1.2;
eF = {'s', 'w', 'w2', 'rls', 'rls2'}; M = zeros(length(deg),length(bias));
for i=1:length(eF), eF{2,i} = M; end;
mse_char = struct(eF{:}); ber = struct(eF{:}); errors = cell(1,2); clear M i eF;

%%
for bits = [2 4 8]
tStart = tic;
cur_var = [bias, deg, deg, bits];
tech = {'pisic', 'misic'};
span = {'syncd', 'syncd_b2b_brief'};
for m = 1:length(span)
clear charinfo, load([rootdir span{m} '\charinfo.mat']);
for k = 1:length(tech)
    signal  = syncd_import(charinfo, cur_var, tech{k});
    [switched, s_info] = sw_cycle(signal);
    [yout, mse, ber, errors{1}] = sw_filter(switched.y_s, switched.xs_slice, s_info);
    [~, ~, ~, errors{2}] = sw_filter(switched.Norm.y_s, switched.xs_slice, s_info);
    errorDistPlot(s_info, errors, sprintf([tech{k} '-%i'], int16(bits)));
    curdir = [rootdir span{m} sprintf(['\\' lower(tech{k}) '-%i\\'], int16(bits))];
    saveas(gcf, [curdir sprintf('BERxGI_%.1fV_%imA.png',deg,int16(1e3*bias))], 'png');
    toc(tStart);
end
end
end
end