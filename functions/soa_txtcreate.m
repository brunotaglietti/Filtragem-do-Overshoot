clear all; clc
bits = 0;
method = {'step-','pisic-','misic-'};

for k = 1:length(method)
for bits = [2, 4, 8]
direc_root = 'C:\Users\Bruno\Documents\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-NL\syncd_b2b\';
strend = '-mod1000mV-pinpd-var-pinsoa-5dbm';
strcall = method{k};
% tim = 0.16;                                   % Duração do pulso em X.XXns
cur = (0.060:0.020:0.180);                      % Corrente de polarização em X.XXXA
deg = (0.00:0.30:1.20);                             % Amplitude do degrau em X.XXV
imp = (0.00:0.30:1.20);                              % Amplitude do impulso em X.XXV
tim = bits/12.5;

direc = [direc_root strcall sprintf('%i',bits) '\'];
if strcmp(strcall(1:4),'step')
    imp = 0; tim = 0; direc = [direc_root 'step' '\'];
end
% step-iX.XXXA-tX.XXns-degX.XXV-impX.XXV.csv

for i = 1:length(cur)
    aux2 = sprintf('%2.0fmA',cur(i)*1e3);
    if cur(i) == 0.005
        clear aux2;
        aux2 = sprintf('05mA');
    end
    mkdir([direc 'dados/' aux2]);
    mkdir([direc 'figs/' aux2]);
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


% % PARA OS PULSOS ELÉTRICOS DE REFERÊNCIA
% 
% strcall = 'electric-misic-';
% strend = '-atten-20db';
% cur = [0.000:0.005:0.000];                      % Corrente de polarização em X.XXXA
% tim = [0.16];                                    % Duração do pulso em X.XXns
% deg = [0:0.25:1.5];                             % Amplitude do degrau em X.XXV
% imp = [0:0.50:1.5];                              % Amplitude do impulso em X.XXV
% 
% % step-iX.XXXA-tX.XXns-degX.XXV-impX.XXV.csv
% 
% for i = 1:length(cur)
%     aux2 = sprintf('%2.0fmA',cur(i)*1e3);
%     mkdir(['electric/dados/']);
%     mkdir(['electric/figs/']);
%     for j = 1:length(tim)
%        for m = 1:length(deg)
%            for n = 1:length(imp)
%                aux1 = sprintf('i%1.3fA-t%1.2fns-deg%1.2fV-imp%1.2fV',cur(i),tim(j),deg(m),imp(n));
%                file = fopen(['electric/dados/' strcall aux1 strend '.h5'],'w');
%                file = fopen(['electric/figs/' strcall aux1 strend '.png'],'w');
%            end
%        end
%     end
% end
% 
% fclose('all');