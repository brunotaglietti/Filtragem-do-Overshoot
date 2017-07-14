close all; clc;
addpath('functions', 'plots');

%% Memory Allocation

Meas_path = 'C:\Users\Bruno\Documents\Projetos Colaborativos\Measurements';
if ~exist('charinfo','var'), uiload; end
% method = cell(1,2); method{1} = charinfo.span;

M = zeros(length(charinfo.deg),length(charinfo.cur));
mse_char = struct('s', M, 'w', M, 'w2', M, 'rls', M, 'rls2', M);
ber =   struct('s', M, 'w', M, 'w2', M, 'rls', M, 'rls2', M); clear M;

%% Processing
t_start = tic;

for bits = [2, 4, 8]
fprintf(sprintf(['\nStarting analysis for ',...
    upper('pisic') '-' num2str(bits) ' technique.\n\n']));
for B = 1:length(charinfo.cur)
for V = 1:length(charinfo.deg)
cur_var = [charinfo.cur(B), charinfo.deg(V), charinfo.deg(V), bits];
signal = soah5import(charinfo, cur_var, 'pisic'); % Import
[switched, s_info] = sw_cycle(signal); % Cycle cropping
[yout, mse_char(V,B), ber(V,B), errors] = sw_filter(switched.y_s, switched.xs_slice, s_info);
toc(t_start);
end
end

%% Saving Results
method = {charinfo.span, 'pisic'};
if ~exist([charinfo.root 'Results\'],'dir'), mkdir([charinfo.root 'Results\']); end
results_file = [charinfo.root 'Results\' charinfo.SOA '_' method{:} sprintf('-%i',bits) '.mat'];
save(results_file, 'yout', 'mse_char', 'ber', 'errors');
end

load handel; sound(y, Fs);