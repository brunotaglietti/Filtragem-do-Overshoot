%% Importação dos Sinais
% Entradas da função são o SOA utilizado, a caracterização em específico (um vetor que
% inclui a corrente de polarização do SOA, amplitude do degrau de chaveamento e amplitude
% do impulso de chaveamento), e o método da caracterização (step, pisic, misic, e número
% de bits de impulso, se aplicável.)

function [signal] = syncd_import(SOA, char_var, method)
% char_var = [Corrente, Degrau, Impulso, bits];
% root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
root_dir = 'E:/Projetos Colaborativos/';
fprintf(['Loading file for ' sprintf('%.0fmA and %.1fV. ',1e3*char_var(1), char_var(2))]);
dir_meas = [root_dir 'chav-amo-SOA-prbs/' SOA '/' method{1} '/' method{2} ...
    sprintf('-%i/dados/%imA',int16(char_var(4)),int16(char_var(1)*1e3)) '/'];

tech = method{2}; imp_time = char_var(4)*8;
if strcmp(tech(1:4),'step'), aux = 'step-'; imp_time = 0;
elseif strcmp(tech(1:4),'pisi'), aux = 'pisic-';
elseif strcmp(tech(1:4), 'misi'), aux = 'misic-';
end
if strcmp(method{1},'syncd'), Pin = 'pinsoa-6dbm';
elseif strcmp(method{1}, 'syncd_b2b_brief'), Pin = 'pinsoa-5dbm';
else, Pin = 'pinsoa-5dbm';
end
name_eval = ['i0.%03iA-t0.%02dns-deg%1.2fV-imp%1.2fV-mod1000mV-pinpd-var-' Pin '.h5'];
file_name = [aux sprintf(name_eval,int16(char_var(1)*1e3),imp_time,char_var(2),char_var(3))];
file_address = [dir_meas file_name];
%% Leitura da Medição
% O osciloscópio salva os arquivos *.h5* em valores brutos,
% registrando o coeficiente de multiplicação no cabeçalho. xInc e xOrg são
% os valores de incremento e offset, respectivamente, que determinam os
% valores absolutos das medidas.


num_WF = double(h5readatt(file_address,'/Waveforms','NumWaveforms'));
signal_length = double(h5readatt(file_address,'/Waveforms/Channel 1','NumPoints'));
signal.y = zeros(signal_length,num_WF); signal.t = signal.y;

for cur_wf = 1:num_WF
    end_dados = sprintf('/Waveforms/Channel %1.0f/', cur_wf);
    end_att = sprintf([end_dados 'Channel %1.0fData'], cur_wf);
    signal.y(:,cur_wf) = (double(h5read(file_address,end_att)) * ...
        h5readatt(file_address, end_dados, 'YInc') + h5readatt(file_address, end_dados, 'YOrg'));
    signal.t(:,cur_wf) = h5readatt(file_address, end_dados, 'XOrg') : ...
        h5readatt(file_address, end_dados, 'XInc') : (signal_length - 1) * ...
        h5readatt(file_address, end_dados, 'XInc') - abs(h5readatt(file_address, end_dados, 'XOrg'));
    signal.t(:,cur_wf) = (signal.t(:,cur_wf) - signal.t(1,cur_wf))'; % Desloca o tempo para iniciar em zero
end

if num_WF > 1
    wnd = 1:1e6;    % DO NOT USE THE WHOLE SIGNAL FOR X-CORR
    wnd = wnd + 1e5;    % Step away from the start for safety
    yxc = abs(xcorr(signal.y(wnd,1), signal.y(wnd,2)));
    [~, yxci] = max(yxc);
    lag = length(wnd) - yxci;
    if lag>0
        y1 = signal.y(1:end - lag,1);
        y2 = signal.y(1 + lag:end,2);
    elseif lag<0
        y1 = signal.y(1 - lag:end,1);
        y2 = signal.y(1:end + lag,2);
    end
    signal.y = [y1, y2];
    t = signal.t(1:length(y1),1);
    signal.t = [t, t];
end
end