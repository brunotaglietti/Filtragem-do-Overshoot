function [signal] = test_file_import(SOA, char_var, method)
% char_var = [Corrente, Degrau, Impulso];
root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
% root_dir = uigetdir;
addpath([root_dir 'MatLab/']);
addpath('functions');

% Diretório de Origem
% method = 'no_switch_test';
% method = 'no_sw_20kfiber';
% method = 'syncd';
dir_meas = [root_dir 'chav-amo-SOA-prbs/' SOA '/syncd/' method '/dados/' ...
    sprintf('%imA',char_var)];
% file_name = ['teste' sprintf('%3.0f',soa_bias) '.h5'];               % Nome dos arqs.

% file_name = ['20kfiber_' sprintf('%i',char_var) '.h5'];
% file_name = ['20kfiber_sw_vs' sprintf('%i',char_var(1)) 'm_vi' sprintf('%i',char_var(2)) 'm_i100.h5'];
% file_name = 'teste1.h5';
file_name = 'misic-prbs-i0.060A-t0.32ns-deg0.00V-imp0.00V-mod500mV-pinpd-12dbm-pinsoa-9dbm.h5';
filename = [method(1:5) 

% ref = '20kfiber_sw_vs0_vi0_i100';

%% Leitura da Medição
% O osciloscópio salva os arquivos *.h5* em valores brutos,
% registrando o coeficiente de multiplicação no cabeçalho. xInc e xOrg são
% os valores de incremento e offset, respectivamente, que determinam os
% valores absolutos das medidas.

file_address = [dir_meas file_name];
num_WF = double(h5readatt(file_address,'/Waveforms','NumWaveforms'));
signal_length = double(h5readatt(file_address,'/Waveforms/Channel 1','NumPoints'));
signal.y = zeros(signal_length,num_WF); signal.t = signal.y;
% signal.yf = signal.y;   signal.y_unb = signal.y;

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