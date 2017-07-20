close all;
% addpath('../functions');

[FileName,Path, ~] = uigetfile('C:\Users\Bruno\Desktop\*.*');
file_address = [Path FileName];
[signal, lag] = test_delay(file_address);
%%
cur_delay = signal.t(lag+5e5,1) - signal.t(5e5,1);
set_delay = 388.794e-6;
disp(['Change skew to: ' sprintf('%.9e', set_delay + cur_delay)]);
