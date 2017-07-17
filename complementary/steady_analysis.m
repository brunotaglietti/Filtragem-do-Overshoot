addpath('complementary', 'functions', 'plots');
if ~exist('charinfo','var') || isempty(strfind(lower(charinfo.span), 'steady'))
    Meas_path = 'E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L\SSMF\Steady';
    [FileName,Path, ~] = uigetfile(Meas_path);
    load([Path FileName]); clear FileName;
end
yout = cell(1,length(charinfo.cur)); mse_char = yout; ber = yout; errors = yout;

for i = 1:length(charinfo.cur)
    bias = charinfo.cur(i);
    cur_var = [bias, charinfo.deg];
    signal = soah5import(charinfo, cur_var, 'Steady');
    P = sampling(signal.t(:,1), signal.y(:,1));
    x_s = [signal.t(P,1) signal.y(P,1)];
    y_s = [signal.t(P,2) signal.y(P,2)];
    t_s = signal.t(P,1);
    [yout{i}, mse_char{i}, ber{i}, errors{i}] = regFilter(y_s, x_s);
end
%%
