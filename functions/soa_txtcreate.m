clear all; clc

charinfo.pinsoa = -6;
charinfo.modV = 1;
charinfo.SOA = 'CIP-L';
charinfo.span = 'syncd';
charinfo.cur = (0.060:0.020:0.140);     % Corrente de polarização em X.XXXA
charinfo.deg = (0.0:0.3:1.2);           % Amplitude do degrau em X.XXV
% imp = (0.00:0.30:1.20);                              % Amplitude do impulso em X.XXV
cur = charinfo.cur; deg = charinfo.deg;
direc_root = ['E:\Projetos Colaborativos\chav-amo-SOA-prbs\',...
    charinfo.SOA, '\', charinfo.span, '\'];
charinfo.root = direc_root;
strend = ['-mod' sprintf('%.0f',charinfo.modV*1e3),...
    'mV-pinpd-var-pinsoa' num2str(charinfo.pinsoa) 'dbm'];

method = {'step-','pisic-','misic-'};
for k = 1:length(method)
for bits = [2, 4, 8]
strcall = method{k};
tim = bits/12.5;

direc = [direc_root strcall sprintf('%i',bits) '\'];
if strcmp(strcall(1:4),'step')
    imp = 0; tim = 0; direc = [direc_root 'step' '\'];
end
for i = 1:length(cur)
    aux2 = sprintf('%.0fmA',cur(i)*1e3);
    if ~exist([direc 'dados/' aux2], 'dir'), mkdir([direc 'dados/' aux2]); end
    if ~exist([direc 'figs/' aux2], 'dir'), mkdir([direc 'figs/' aux2]); end
    for j = 1:length(tim)
       for m = 1:length(deg)
%            for n = 1:length(imp)
%                aux1 = sprintf('i%1.3fA-t%1.2fns-deg%1.2fV-imp%1.2fV',cur(i),tim(j),deg(m),imp(n));
               aux1 = sprintf('i%1.3fA-t%1.2fns-deg%1.2fV-imp%1.2fV',cur(i),tim(j),deg(m),deg(m));
               file = fopen([direc 'dados\' aux2 '\' strcall aux1 strend '.h5'],'w');
               file = fopen([direc 'figs\' aux2 '\' strcall aux1 strend '.png'],'w');
%            end
       end
    end
end

fclose('all');
end
end
save([direc_root 'charinfo.mat'],'charinfo');