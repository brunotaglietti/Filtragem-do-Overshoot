%% Amostragem do sinal
% O sinal [y, t] adquirido do osciloscópio é superamostrado. Essa função amostra o sinal
% já chaveado na frequência de amostragem fmod. Os cruzamentos do sinal com "zero" (média
% do sinal) auxiliam a determinação dos pontos de amostragem.

function [P, varargout] = sampling(y,t,fmod)
if nargin < 3, fmod = 6.9994e9; end
Tmod = 1/fmod;
avg = sum(y)/length(y);
yub = y - avg;
zx = find(yub(2:end) .* yub(1:end-1)<0);

% *zx* (zero cross) é os pontos da curva que atravessam a média. Devido ao
% ruído, o cruzamento por zero pode acontecer várias vezes
Hf = -1./((zx(1:end-1) - zx(2:end))*(t(2)-t(1)));
zx_Hf = find(Hf>2.01*fmod);
zx(zx_Hf) = [];
zx = sort(zx);

t_est = t(1):Tmod:t(zx(1));
finish = length(t_est);
for n = 1:length(zx)-1
    ts_window = t(zx(n)) + Tmod/2 : Tmod : t(zx(n+1));
    start = finish + 1;
    finish = finish + length(ts_window);
    t_est(start:finish) = ts_window;
end
ts_window = t(zx(end)) + Tmod/2 : Tmod : t(end);
start = finish + 1;
finish = finish + length(ts_window);
t_est(start:finish) = ts_window;

P = zeros(1,length(t_est));
for n = 1:length(t_est)
    P(n) = round((t_est(n) - t(1))/(t(end) - t(1)) * (length(t) - 1) + 1);
end
if nargout > 1, varargout{1} = y(P);
elseif nargout > 2, varargout{2} = t(P);
end