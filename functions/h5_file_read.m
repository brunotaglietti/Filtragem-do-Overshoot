function [ signal ] = h5_file_read(address, filename)
%H5_FILE_READ Reads the h5 file and stores in the signal structure variable.
%   Detailed explanation goes here

file_address = [address filename];
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
    y1 = signal.y(1:end - lag,1);
    y2 = signal.y(1 + lag:end,2);
    signal.y = [y1, y2];
    t = signal.t(1:length(y1),1);
    signal.t = [t, t];
end

end

