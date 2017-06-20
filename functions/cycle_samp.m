function [pout, yout] = cycle_samp(y,t,fmod)
if nargin < 3, fmod = 6.985e9; end
addpath('functions');
spbit = round(1/fmod/(t(2)-t(1)));

ym = mean(y);
ts = t(2) - t(1);   % Tempo de amostragem
fs = 1/ts;          % Freq. de amostragem
fp1 = 1.0e9;        % Borda da Banda de Passagem
fp2 = 2.0e9;        % Borda da Banda de Rejeição
Rp = 0.5;           % Ripple na Banda de Passagem
As = 1000;          % Att na Banda de Rejeição
[B,~] = filter_lp(2*pi*fp1/(fs), 2*pi*fp2/(fs),Rp,As,'Bar');
yf = conv(y - ym, B, 'same');
yub = y - yf;

zx = find(yub(2:end) .* yub(1:end-1)<0);
% quando muda o sinal da amostra, esse produto dá negativo
Hf = -1./((zx(1:end-1) - zx(2:end))*(t(2)-t(1)));
zx_Hf = find(Hf>2.01*fmod);
if length(zx_Hf)>1
    if zx_Hf(1) == 1
        zx_Hf(1) = [];
    end
    if zx_Hf(end) == length(zx)
        zx_Hf(end) = [];
    end
end

zx(zx_Hf) = [];
Hf = -1./((zx(1:end-1) - zx(2:end))*(t(2)-t(1)));
zx_Lf = find(Hf < 0.51*fmod);
for i = 1:length(zx_Lf)
    aux1 = floor((zx(zx_Lf(i)+1) - zx(zx_Lf(i)))/spbit);
    aux2 = round((zx(zx_Lf(i)+1) - zx(zx_Lf(i)))/(aux1+1));
    for j = 1:aux1
        zx(end+1) = zx(zx_Lf(i)) + j*aux2;
    end
end
zx = sort(zx);

hsm = zeros(length(zx)-1,1);
p_hsm = zeros(length(zx)-1,1);
for i = 1:length(zx)-1
    hsm(i) = mean(yub(zx(i):zx(i+1))) + mean(y(zx(i):zx(i+1)));
    p_hsm(i) = floor((zx(i+1) - zx(i))/2) + zx(i);
end
pout = p_hsm;
if nargout > 1, yout = hsm; end