function [signal] = switch_file_import(SOA, parameters)
% switch_file_import  importa a medi��o desejada.
%   [y, t, yf, y_unb] = switch_file_import(tim, imp, deg, cur) tem como
%   entrada os valores de dura��o de pr�-�nfase (|tim|), amplitide do
%   impulso (|imp|), amplitude do degrau de chaveamento (|deg|), e
%   amplitude da corrente de polariza��o (|cur|). As sa�das s�o a
%   intensidade da medi��o |y|, os valores de tempo |t|, |yf| � o sinal |y|
%   filtrado, e |y_unb| � a subtra��o |y - yf|.

vars = num2cell(parameters.var);    [tim, imp, deg, cur] = vars{:};
tech = parameters.tech;          bitstream = parameters.bitstream;

root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
% root_dir = uigetdir;
addpath([root_dir 'MatLab/']);
addpath('functions');

if strcmp(bitstream,'prbs'), aux1 = '-prbs';
else aux1 = ''; end

% Diret�rio de Origem
strsoa = [root_dir 'chav-amo-SOA-prbs/' SOA '/optical' aux1 '/'];
strend = '-mod500mV-pinpd-12dbm-pinsoa-9dbm';               % Nome dos arqs.
str_aux = 'i%1.3fA-t%1.2fns-deg%1.2fV-imp%1.2fV';           % Medida
strpath = [strsoa tech '-' sprintf('%d',round(tim/.08))];   % Diret�rio de Destino
if strcmp(tech,'step'), strpath = [strsoa tech]; end
aux1 = sprintf(str_aux,cur,tim,deg,imp);
strcall = [aux1 strend];
if strcmp(bitstream,'prbs')
    strpath = [strpath '_' upper(bitstream) '/'];
    strcall = [tech '-' bitstream '-' strcall];
else
    strpath = [strpath '/'];
    strcall = [tech '-' strcall];
end
warning off MATLAB:MKDIR:DirectoryExists
mkdir([strpath 'script/csv/' sprintf('%2.0fmA',cur*1e3) '/']);
mkdir([strpath 'script/figs/' sprintf('%2.0fmA',cur*1e3) '/']);
aux2 = [strpath 'dados/' sprintf('%2.0fmA',cur*1e3) '/'];

%% Leitura da Medi��o
% O oscilosc�pio salva os arquivos *.h5* em valores normalizados,
% registrando o coeficiente de multiplica��o no cabe�alho. xInc e xOrg s�o
% os valores de incremento e offset, respectivamente, que determinam os
% valores absolutos das medidas.

nome_arq = [aux2 strcall '.h5'];
end_arq = '/Waveforms/Channel 1/';
signal.y = (double(h5read(nome_arq,[end_arq 'Channel 1Data'])) * ...
    h5readatt(nome_arq,end_arq,'YInc')+h5readatt(nome_arq,end_arq,'YOrg'));
signal.t = h5readatt(nome_arq,end_arq,'XOrg'):h5readatt(nome_arq,end_arq,'XInc'):(length(signal.y)-1)*...
    h5readatt(nome_arq,end_arq,'XInc')-abs(h5readatt(nome_arq,end_arq,'XOrg'));
signal.t = (signal.t-signal.t(1))';          % Desloca o tempo para iniciar em zero

ts = signal.t(2) - signal.t(1);      % Tempo de amostragem
fs = 1/ts;              % Freq. de amostragem

fp1 = 1e9;       % Borda da Banda de Passagem
fp2 = 2e9;       % Borda da Banda de Rejei��o
Rp = 0.5;         % Ripple na Banda de Passagem
As = 1000;      % Att na Banda de Rejei��o
[B,~] = filter_lp(2*pi*fp1/(fs),...
    2*pi*fp2/(fs),Rp,As,'Bar');
signal.yf = conv(B,signal.y);
yfxc = xcorr(signal.y,signal.yf); % Correla��o cruzada
[~,i] = max(yfxc); lag = length(signal.y)-i;
signal.yf = signal.yf(1-lag:end+lag);
signal.y_unb = signal.y - signal.yf; % Sinal y subtraido de yf
% Resultado � y ao redor de zero, "unbiased".
end