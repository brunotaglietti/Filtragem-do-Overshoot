close all; clc

[FileName,Path, ~] = uigetfile('C:\Users\Bruno\Desktop\*.*');
file_address = [Path FileName];
[signal, lag] = test_delay(file_address);

cur_delay = signal.t(lag+1000,1) - signal.t(1+1000,1);
set_delay = 123.939e-6;
disp(['Change skew to: ' sprintf('%.9e', set_delay + cur_delay)]);