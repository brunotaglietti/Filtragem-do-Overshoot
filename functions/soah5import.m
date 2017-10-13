%% Importa��o dos Sinais
% Entradas da fun��o s�o o SOA utilizado, a caracteriza��o em espec�fico (um vetor que
% inclui a corrente de polariza��o do SOA, amplitude do degrau de chaveamento e amplitude
% do impulso de chaveamento), e o m�todo da caracteriza��o (step, pisic, misic, e n�mero
% de bits de impulso, se aplic�vel.)

function [signal] = soah5import(charinfo, cur_var, tech)
fprintf(['\nLoading ' strrep(charinfo.span, '\', ' ') ' file for ',...
    sprintf('%.0fmA and %.1fV.\n',1e3*cur_var(1), cur_var(2))]);
file_address = dirOrg(charinfo, cur_var, tech);
%% Leitura da Medi��o
% O oscilosc�pio salva os arquivos *.h5* em valores brutos,
% registrando o coeficiente de multiplica��o no cabe�alho. xInc e xOrg s�o
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
    wnd = 1:1e7;    % DO NOT USE THE WHOLE SIGNAL FOR X-CORR
    wnd = wnd + 1e5;    % Step away from the start for safety
    yxc = abs(xcorr(signal.y(wnd,1), signal.y(wnd,2)));
    [~, yxci] = max(yxc);
    lag = length(wnd) - yxci;
    if lag>=0
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

function file_address = dirOrg(charinfo, cur_var, tech)
bias = cur_var(1);
deg = cur_var(2);

if strcmpi(charinfo.span(1:4),'sync')
    if strcmpi(tech(1:4),'step')
        imp = 0;
        imp_time = 0;
        techdir = [tech sprintf('\\dados\\%imA\\', int16(cur_var(4)))];
    else
        imp = cur_var(3);
        imp_time = cur_var(4)*8;
        techdir = [tech sprintf('-%i\\dados\\%imA\\', int16(cur_var(4)), int16(1e3*bias))];
    end
else
    if strcmpi(tech(1:4),'step') || ~isempty(strfind(lower(tech),'steady'))
        imp = 0;
        imp_time = 0;
        techdir = [tech '\dados\'];
    else
        imp = cur_var(3);
        imp_time = cur_var(4)*8;
        techdir = [tech sprintf('-%i\\dados\\', int16(cur_var(4)))];
    end
end

dir_meas = [charinfo.root  techdir];
Pin = ['pinsoa' num2str(charinfo.pinsoa) 'dbm'];
name_eval = ['i0.%03iA-t0.%02dns-deg%1.2fV-imp%1.2fV-mod',...]
    sprintf('%.0f',charinfo.modV*1e3) 'mV-pinpd-var-' Pin '.h5'];
file_name = [lower(tech) '-' sprintf(name_eval,int16(bias*1e3),imp_time,deg,imp)];
file_address = [dir_meas file_name];
end