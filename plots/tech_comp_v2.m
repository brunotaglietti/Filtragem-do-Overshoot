close all
rootdir = 'E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L - 2017.07.20\';
addpath('complementary', 'functions', 'plots');
spans = {'SSMF', 'NZD_25', 'NZD_50', 'NZD_75',...
    'NZD_25_DC', 'NZD_50_DC', 'NZD_75_DC'};
swTechs = {'pisic', 'misic'};
bitses = [2, 4, 8];
biasses = [.08, .10, .12];
BERxGI = cell(  length(spans),...
                length(biasses),...     0.08    0.10    0.12
                length(swTechs)+1,...   step    pisic   misic
                length(bitses)); %      2(0)     4       8

tStart = tic;
for S = 1:length(spans)
curdir = [rootdir spans{S} '\'];
load([curdir 'charinfo.mat']);
for ib = 1:length(charinfo.cur)
bias = biasses(ib);
deg = charinfo.deg; imp = charinfo.imp;
tech = 'step';
cur_var = [bias, deg, 0, 0];
signal = soah5import(charinfo,cur_var,tech); % Import
[switched, s_info] = sw_cycle(signal);
[~, ~, ber, errors] = sw_filter(switched.y_s, switched.xs_slice, s_info);
BERxGI{S,ib,1,1} = errorDistPlot(s_info, errors, [spans{S} ' - ' tech]);
saveas(gcf, ['.\All Results\BERxGI_' spans{S} '_' sprintf('%imA_',int16(1e3*bias)),...
         tech '.png'], 'png');
toc(tStart); close all;
for T = 1:length(swTechs)
for ibits = 1:length(bitses)
    bits = bitses(ibits);
    tech = swTechs{T};
    spTech = sprintf([tech '-%i'], int16(bits));
    cur_var = [bias, deg, imp, bits];
    signal = soah5import(charinfo,cur_var,tech); % Import
    [switched, s_info] = sw_cycle(signal);
    [~, ~, ber, errors] = sw_filter(switched.y_s, switched.xs_slice, s_info);
    BERxGI{S,ib,T+1,ibits} = errorDistPlot(s_info, errors, [spans{S} ' - ' spTech]);
    saveas(gcf, ['.\All Results\BERxGI_' spans{S} '_' sprintf('%imA_',int16(1e3*bias)),...
         upper(spTech) '.png'], 'png');
    toc(tStart); close all;
end
end
end
end
save('.\All Results\BERxGI','BERxGI')
% load handel
% sound(y(1:5e4),Fs)
system('shutdown -s')