clear all; clc

spans = {'B2B', 'SSMF', 'NZD_25', 'NZD_50', 'NZD_75',...
    'NZD_25_DC', 'NZD_50_DC', 'NZD_75_DC'};
sw_mode = {'Steady', 'Switched'};

for Fiber = 1:length(spans)
for SW = 1:length(sw_mode)

charinfo.span = [spans{Fiber} '\' sw_mode{SW}];
charinfo.sw_period = 2*100/12.5e9;
charinfo.fmod = 6.9994e9;
charinfo.pinpd = 'var';
charinfo.pinsoa = -6;
charinfo.modV = 1;
charinfo.SOA = 'CIP-L';
charinfo.cur = (0.080:0.020:0.120);
charinfo.deg = 1.2;
charinfo.imp = 1.2;

cur = charinfo.cur; deg = charinfo.deg;
direc_root = ['E:\Projetos Colaborativos\chav-amo-SOA-prbs-testes\',...
    charinfo.SOA, '\', charinfo.span, '\'];
charinfo.root = direc_root;

if ~exist('direc_root', 'dir'), mkdir(direc_root); end
save([direc_root 'charinfo.mat'],'charinfo');

strend = ['-mod' sprintf('%.0f',charinfo.modV*1e3) 'mV-',...
    'pinpd-' charinfo.pinpd,...
    '-pinsoa' num2str(charinfo.pinsoa) 'dbm'];

method = {'step-','pisic-','misic-'};
for k = 1:length(method)
for bits = [2, 4, 8]
strcall = method{k};
tim = bits/12.5;

direc = [direc_root strcall sprintf('%i',bits) '\'];
if strcmpi(sw_mode{SW},'Steady')
    imp = 0; tim = 0; strcall = []; direc = [direc_root '\'];
elseif strcmpi(strcall(1:4),'step')
    imp = 0; tim = 0; direc = [direc_root 'step' '\'];
end
for i = 1:length(cur)
    if ~exist([direc 'dados/'], 'dir'), mkdir([direc 'dados/']); end
    if ~exist([direc 'figs/'], 'dir'), mkdir([direc 'figs/']); end
    for j = 1:length(tim)
       for m = 1:length(deg)
           aux1 = sprintf('i%1.3fA-t%1.2fns-deg%1.2fV-imp%1.2fV',cur(i),tim(j),deg(m),imp);
           file = fopen([direc 'dados\' strcall aux1 strend '.h5'],'w');
           file = fopen([direc 'figs\' strcall aux1 strend '.png'],'w');
       end
    end
end

fclose('all');
end
end

end
end