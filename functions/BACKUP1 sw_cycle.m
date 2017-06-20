%% Segmentação e amostragem dos Ciclos de Chaveamento
% Cada ciclo de chaveamento deve ser isolado para processamento individual,
% para que se evite a acumulação de estatísticas inválidas para o chaveamento usual.
%
% O ponto _riseedge_ representa a borda de subida da chave, e é encontrado
% utilizando o nível de subida definido anteriormente em _rise thresh_. A
% borda de descida é determinada de forma similar. No gráfico, a seção da
% curva mais escura denota o período do qual o sinal encontra-se chaveado.
%
% Antes de entrar no _loop_ de iterações, define-se o número total de
% ciclos de chaveamento, segmenta-se  o primeiro intervalo e prepara-se a
% representação gráfica para sua atualização iterativa.
% 
% Após a definição dos pontos de fechamento e abertura da chave, é feita a
% amostragem do sinal, guardando os pontos amostrados em um novo vetor, que
% será utilizado nas seções seguintes. No gráfico, os pontos amostrados são
% apresentados em forma de pequenos círculos.

function [switched, s_info] = sw_cycle(signal,pulselength)

if ~exist('pulselength','var'), pulselength = 100/(12.5e9); end;
fs = 1/(signal.t(2)-signal.t(1));
samples = round(pulselength*2*fs);

y = signal.y;   yf = signal.yf;     y_unb = signal.y_unb;   t = signal.t;
y_avg = zeros(samples,1);
N_cycles = floor(length(signal.y) / samples);
for n = 1:N_cycles, range = (n - 1)*samples + 1 : samples*n;
    y_avg = y_avg + signal.y(range); end
y_avg = y_avg / N_cycles;
y_avg = [y_avg; y_avg];

rise_thresh = (max(y_avg) - min(y_avg)) / 10*6 + min(y_avg);   % 70% da subida (em y)
fall_thresh = (max(y_avg) - min(y_avg)) / 10*2 + min(y_avg);   % 30% da subida

if(y_avg(samples)<rise_thresh)     % Condição de chave aberta no ponto _samples_.
    riseedge = find(y_avg>rise_thresh,1,'first');
    falledge = find(y_avg(riseedge:end)<fall_thresh,1,'first') + riseedge;
elseif(y_avg(round(samples))>fall_thresh)    % Condição de chave fechada no ponto _samples_.
    falledge = find(y_avg<fall_thresh,1,'first');
    riseedge = find(y_avg(falledge:end)>rise_thresh,1,'first') + falledge;
end

interv1 = riseedge - round(samples/4);
if interv1 < 1
    interv1 = falledge + round(samples/4);
    riseedge = riseedge + samples - 1; falledge = falledge + samples - 1;
end
interv2 = interv1 + samples - 1; i12 = interv1:interv2;
sw_t = (riseedge:falledge);
N_cycles = floor(length(y(interv1:end)) / samples/2); % Numero de ciclos de chaveamento
Samp_Cy = zeros(N_cycles,1);    cy_avg = zeros(N_cycles,1); mod = zeros(N_cycles,1);

% Alocação de memória
y_C = cell(N_cycles,1);         y_C{1} = y(i12);
yf_cycle = cell(N_cycles,1);    yf_cycle{1} = yf(i12);
yub_cycle = cell(N_cycles,1);   yub_cycle{1} = y_unb(i12);
y_s = cell(N_cycles, 1);        ys_dd = cell(N_cycles, 1);
tcur = t(sw_t);

for i = 1 : N_cycles
    sw_t = sw_t + samples;
    yf_cycle{i} = yf(sw_t);         yub_cycle{i} = y_unb(sw_t);
    y_C{i} = [t(sw_t), y(sw_t)];
    P = sampling(y(sw_t),tcur);
    y_s{i} = [t(sw_t(P)), y(sw_t(P)), P'];
    Samp_Cy(i) = length(P);         cy_avg(i) = mean(y(sw_t));
end
switched.y = y_C;
switched.yf = yf_cycle;
switched.yub = yub_cycle;
switched.y_samp = y_s;
s_info.Samp_Cy = Samp_Cy;
s_info.N_cycles = N_cycles;
s_info.mean = mean(cy_avg);
for i = 1 : N_cycles, ys_cur = y_s{i}; mod(i) = mean(abs(ys_cur(:,2) - s_info.mean)); end
s_info.mod = mean(mod);
for i = 1 : N_cycles
    ys_cur = y_s{i};
    pos = ys_cur >= s_info.mean; ys_cur(pos) = s_info.mean + s_info.mod;
    neg = ys_cur < s_info.mean; ys_cur(neg) = s_info.mean - s_info.mod;
    ys_dd{i} = ys_cur;
end
switched.ys_dd = ys_dd;
end