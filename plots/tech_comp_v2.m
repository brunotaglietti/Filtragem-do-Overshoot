close all
rootdir = 'E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L - 2017.07.20\';
addpath('complementary', 'functions', 'plots');
spans = {'SSMF', 'NZD_25', 'NZD_50', 'NZD_75',...
    'NZD_25_DC', 'NZD_50_DC', 'NZD_75_DC'};

% for S = 1:length(spans)
S = 1;
curdir = [rootdir spans{S} '\'];
load([curdir 'charinfo.mat']);
%% UI Configuration and Memory Allocation


for bias = charinfo.cur
deg = charinfo.deg; imp = charinfo.imp;
eF = {'s', 'w', 'w2', 'rls', 'rls2'}; M = zeros(length(deg),length(bias));
for i=1:length(eF), eF{2,i} = M; end;
mse_char = struct(eF{:}); %ber = struct(eF{:}); %errors = cell(1,2);
clear M i eF;

%%
tStart = tic;
swTechs = {'pisic', 'misic'};
tech = 'step';
cur_var = [bias, deg, 0, 0];
signal = soah5import(charinfo,cur_var,tech); % Import
[switched, s_info] = sw_cycle(signal);
[yout, mse, ber, errors] = sw_filter(switched.y_s, switched.xs_slice, s_info);
errorDistPlot(s_info, errors, spTech);
saveas(gcf, [rootdir spans{S} '_' tech,...
    sprintf('_BERxGI_%.1fV_%imA.png',deg,int16(1e3*bias))], 'png');
toc(tStart);
for T = 1:length(swTechs)
for bits = [2 4 8]
    tech = swTechs{T};
    spTech = sprintf([tech '-%i'], int16(bits));
    cur_var = [bias, deg, imp, bits];
    signal = soah5import(charinfo,cur_var,tech); % Import
    [switched, s_info] = sw_cycle(signal);
    [yout, mse, ber, errors] = sw_filter(switched.y_s, switched.xs_slice, s_info);
    errorDistPlot(s_info, errors, spTech);
    saveas(gcf, [rootdir 'BERxGI_' spans{S} '_' sprintf('%imA_',int16(1e3*bias)),...
         upper(spTech) '.png'], 'png');
    toc(tStart); close all;
end
end
end

% end
load handel
sound(y(1:5e4),Fs)