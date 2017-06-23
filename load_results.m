%% Viewing results

close all; clc;
addpath('functions', 'plots'); global fignum;

%% UI Configuration and Memory Allocation
if ~exist('charinfo','var')
    [FileName,PathName, ~] = uigetfile('E:\Projetos Colaborativos\chav-amo-SOA-prbs');
    load([PathName FileName]); charinfo.Path = PathName; clear FileName PathName;
end
choices = {'PISIC-2', 'PISIC-4', 'PISIC-8', 'MISIC-2', 'MISIC-4', 'MISIC-8'};
choicen = menu('Switching Technique',choices); choice = choices{choicen};
if ~strcmpi(choice,'step')
    bits = int16(str2double(choice(end))); tech = lower(choice(1:5));
else, bits = 0; tech = 'step';
end
method = {charinfo.span, choice};
%% Load

results_file = [charinfo.Path 'Results\' charinfo.SOA '_',...
    lower([method{:}]) '.mat'];
load(results_file)
%% Plots
close all;
fignum = 1; fprintf('\nPlotting Section\n');
if length(charinfo.deg) == 1 && length(charinfo.cur) > 1, charinfo.cur_plot(charinfo.cur, mse_char, 'MSE');
elseif length(charinfo.deg) > 1, VIplot(charinfo.cur, charinfo.deg, mse_char, 'MSE', [0 1]);
    VIplot(charinfo.cur, charinfo.deg, ber, 'BER',[-3 -.1]);
end