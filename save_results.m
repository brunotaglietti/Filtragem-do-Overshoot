close all; clc;
addpath('functions', 'plots');

%% Memory Allocation

[FileName,PathName, ~] = uigetfile('E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L\');
load([PathName FileName]); charinfo.Path = PathName; clear FileName PathName;
method = cell(1,2); method{1} = charinfo.span;
M = zeros(length(charinfo.deg),length(charinfo.cur));
mse_char = struct('s', M, 'w', M, 'w2', M, 'rls', M, 'rls_i', M, 'rls2', M);
ber =   struct('s', M, 'w', M, 'w2', M, 'rls', M, 'rls_i', M, 'rls2', M); clear M;

%% Processing
t_start = tic;
techs = {'pisic','misic'};
for kth = 1:length(techs)
for bits = [2, 4, 8]
method{2} = techs{kth}; tech = techs{kth};
fprintf(sprintf(['\nStarting analysis for ',...
    upper(techs{kth}) '-' num2str(bits) ' technique.\n\n']));
for B = 1:length(charinfo.cur)
for V = 1:length(charinfo.deg)
cur_var = [charinfo.cur(B), charinfo.deg(V), charinfo.deg(V), bits];
signal = syncd_import(charinfo, cur_var, tech); % Import
[switched, s_info] = sw_cycle(signal); % Cycle cropping
[yout, mse_char(V,B), ber(V,B), errors] = sw_filter(switched, s_info); % Filtering
toc(t_start);
end
end

%% Saving Results
if ~exist([charinfo.Path 'Results\'],'dir'), mkdir([charinfo.Path 'Results\']); end
results_file = [charinfo.Path 'Results\' charinfo.SOA '_' method{:} sprintf('-%i',bits) '.mat'];
save(results_file, 'yout', 'mse_char', 'ber', 'errors');
end
end
load handel; sound(y, Fs);