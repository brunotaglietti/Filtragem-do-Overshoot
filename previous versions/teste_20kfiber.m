root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
% root_dir = uigetdir;
addpath([root_dir 'MatLab/']);
addpath('functions');

% Diretório de Origem
SOA = 'CIP-L';
soa_bias = 125;
% method = '/no_sw_20kfiber/';
method = '/syncd/';
dir_meas = [root_dir 'chav-amo-SOA-prbs/' SOA method];
file_name = ['20kfiber_' sprintf('%i',soa_bias) '.h5'];
% file_name = ['20kfiber_150ma_124us.h5'];

%%
file_address = [dir_meas file_name];
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

duration = signal.t(end) - signal.t(1);
samp_delay = round(length(signal.t)*(124e-6)/duration);

wnd = 1:5e6;    % DO NOT USE THE WHOLE SIGNAL FOR X-CORR

% test_delay = round(1.2*samp_delay/5);
if num_WF > 1
%     wnd = wnd + 1e5;    % Step away from the start for safety
    yxc = abs(xcorr(signal.y(wnd,1), signal.y(wnd,2)));
    [~, yxci] = max(yxc);
    lag = length(wnd) - yxci;
    
    if ishandle(1), close(1); end; fig1 = figure(1);
    stem(yxc)
    
%     y1 = signal.y(1:end - lag,1);
%     y2 = signal.y(1 + lag:end,2);
%     signal.y = [y1, y2];
%     t = signal.t(1:length(y1),1);
%     signal.t = [t, t];
end

fmod = 6.9994e9;
tbit = 1/fmod;
ts = signal.t(2)-signal.t(1);
samp_bit = tbit/ts;
block_length = round(2048*samp_bit)

wnd = 1:1e3;
perdas = lag/length(signal.t)
% tic;
% while(toc<5)
%     wnd = wnd + 10;
%     plot(signal.t(wnd,1),signal.y(wnd,1),'b'), hold on
%     plot(signal.t(wnd,2),signal.y(wnd,2),'r')
%     xlim([signal.t(wnd(1),1), signal.t(wnd(end),1)]), drawnow;
% end

% tic;
% while(toc<5)
%     wnd = wnd + 10;
%     plot(signal.t(wnd,1),signal.y(wnd,1),'b'), hold on
%     plot(signal.t(wnd,1),signal.y(wnd+block_length-280,1),'r')
%     xlim([signal.t(wnd(1),1), signal.t(wnd(end),1)]), drawnow;
% end