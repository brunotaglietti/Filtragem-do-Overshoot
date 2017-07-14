addpath('functions', 'plots');
if ~exist('charinfo','var')
    Meas_path = 'E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L\SSMF\Steady';
    [FileName,Path, ~] = uigetfile(Meas_path);
    load([Path FileName]); clear FileName;
end

% eF = {'s', 'w', 'w2', 'rls', 'rls2'}; M = 0;
% for i=1:length(eF), eF{2,i} = M; end;
% mse_char = struct(eF{:}); ber = struct(eF{:}); clear M i eF;

cur_var = [charinfo.cur(1), charinfo.deg];
signal = soah5import(charinfo, cur_var, 'Steady');
P = sampling(signal.t(:,1), signal.y(:,1));
x_s = [signal.t(P,1) signal.y(P,1)];
y_s = [signal.t(P,2) signal.y(P,2)];
t_s = signal.t(P,1);
% [yout, mse_char, ber, errors] = regFilter(y_s, x_s);
%%
fp = {'.','markersize',12};
r = 1:1000;
rs = 1:round(r(end)/11);
plot(signal.t(r,1), signal.y(r,1)), hold on
plot(signal.t(r,2), signal.y(r,2))
plot(x_s(rs,1), x_s(rs,2),fp{:})
plot(y_s(rs,1), y_s(rs,2),fp{:})
grid on