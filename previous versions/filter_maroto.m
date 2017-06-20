function [ yf, y_unb ] = filter_maroto(y)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

fs = 80e9;
fp1 = 1e9;       % Borda da Banda de Passagem
fp2 = 2e9;       % Borda da Banda de Rejeição
Rp = 0.5;         % Ripple na Banda de Passagem
As = 1000;      % Att na Banda de Rejeição
[B,~] = filter_lp(2*pi*fp1/(fs),...
    2*pi*fp2/(fs),Rp,As,'Bar');
yf = conv(B,y);
yfxc = xcorr(y, yf); % Correlação cruzada
[~,i] = max(yfxc); lag = length(y)-i;
yf = yf(1-lag:end+lag);
y_unb = y - yf; % Sinal y subtraido de yf
% Resultado é y ao redor de zero, "unbiased".
end

