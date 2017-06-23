%% Segmentação e amostragem dos Ciclos de Chaveamento
% Cada ciclo de chaveamento deve ser isolado para processamento individual, para que se 
% evite a acumulação de estatísticas inválidas para o chaveamento usual.
%
% O ponto _riseedge_ representa a borda de subida da chave, e é encontrado utilizando o 
% nível de subida definido anteriormente em _rise thresh_. A borda de descida é 
% determinada de forma similar. No gráfico, a seção da curva mais escura denota o período
% do qual o sinal encontra-se chaveado.
%
% Antes de entrar no _loop_ de iterações, define-se o número total de ciclos de
% chaveamento, segmenta-se  o primeiro intervalo e prepara-se a representação gráfica para
% sua atualização iterativa.
% 
% Após a definição dos pontos de fechamento e abertura da chave, é feita a amostragem do 
% sinal, guardando os pontos amostrados em um novo vetor, que será utilizado nas seções
% seguintes. A função também adquire informações sobre o sinal, como média do sinal 
% enquanto a chave está fechada, módulo, seções de tempo de cada ciclo, e outros.
% Utilizando essas informações, a função também retorna o sinal na saída de um slicer.

function [switched, s_info] = sw_cycle(signal,pulselength)
fprintf('Fragmenting signal into individual cycles. ')
%%
if ~exist('pulselength','var'), pulselength = 100/12.5e9; end
fs = 1/(signal.t(2) - signal.t(1));
samples = round(pulselength*2*fs);
opt_ch = size(signal.y,2);
y = signal.y(:,opt_ch);   t = signal.t(:,opt_ch);
x = signal.y(:,1);

N_cycles = floor(length(y) / samples);
y_avg = zeros(samples,1);
if N_cycles > 1000, last_cycle = 1000; else, last_cycle = N_cycles; end
for n = 1:last_cycle
    range = (n - 1)*samples + 1 : samples*n;
    y_avg = y_avg + y(range);
end
y_avg = y_avg / N_cycles;   y_avg = [y_avg; y_avg];
y_opening = max(y_avg) - min(y_avg);

t_avg = signal.t(1:length(y_avg),1);

%%
rise_thresh = mean(y_avg) + 0.1*y_opening;
fall_thresh = mean(y_avg) - 0.1*y_opening;
if(y_avg(samples) <= mean(y_avg))     % Condição de chave aberta no ponto _samples_.
    riseedge = find(y_avg>rise_thresh,1,'first');
    falledge = find(y_avg(riseedge:end)<fall_thresh,1,'first') + riseedge;
elseif(y_avg(samples) > mean(y_avg))    % Condição de chave fechada no ponto _samples_.
    falledge = find(y_avg(samples:end)<fall_thresh, 1, 'first') + samples;
    riseedge = samples - find(y_avg(samples:-1:samples/2*.9)>rise_thresh, 1, 'last');
end
interv1 = riseedge - round(samples/4);
if interv1 < 1
    interv1 = falledge + round(samples/4);
    riseedge = riseedge + samples - 1;
end
interv2 = interv1 + samples - 1;

offIni = round(riseedge - .3*samples); offFin = round(riseedge - .1*samples);
swThresh = max(y_avg(offIni:offFin));

swIni = riseedge - find(y_avg(riseedge:-1:offFin) < swThresh, 1, 'first') + 1;
swFin = swIni + round(samples/2);
sw_t = (swIni:swFin);
N_cycles = floor(length(y(interv1:end)) / samples/2); % Numero de ciclos de chaveamento

%% Alocação de memória
Samp_Cy = zeros(N_cycles,1);
cy_avg = zeros(N_cycles,1);     cx_avg = zeros(N_cycles,1);
ymod = zeros(N_cycles,1);       xmod = zeros(N_cycles,1);
y_c = cell(N_cycles,1);         y_c{1} = y(sw_t);
x_c = cell(N_cycles,1);         x_c{1} = x(sw_t);
y_s = cell(N_cycles,1);         x_s = cell(N_cycles,1);
ys_slice = cell(N_cycles, 1);      xs_slice = cell(N_cycles,1);
t_wholeCy = cell(N_cycles,1);

for i = 1 : N_cycles
    t_wholeCy{i} = (interv1:interv2) + samples*(i-1);
    P = sampling(t(sw_t), x(sw_t));
    y_c{i} = [t(sw_t), y(sw_t)];
    x_c{i} = [t(sw_t), x(sw_t)];
    y_s{i} = [t(sw_t(P)), y(sw_t(P)), P'];
    x_s{i} = [t(sw_t(P)), x(sw_t(P)), P'];
    Samp_Cy(i) = length(P);
    cy_avg(i) = mean(y(sw_t));  cx_avg(i) = mean(x(sw_t));
    sw_t = sw_t + samples;
end

switched.y = y_c;   switched.y_s = y_s;
switched.x = x_c;   switched.x_s = x_s;
s_info.Samp_Cy = Samp_Cy;
s_info.N_cycles = N_cycles;
s_info.t_wholeCy = t_wholeCy;
s_info.y_mean = mean(cy_avg);   s_info.x_mean = mean(cx_avg);

for i = 1 : N_cycles
    ys_cur = y_s{i};    xs_cur = x_s{i};
    ymod(i) = mean(abs(ys_cur(:,2) - s_info.y_mean));
    xmod(i) = mean(abs(xs_cur(:,2) - s_info.x_mean));
end
s_info.y_mod = mean(ymod);      s_info.x_mod = mean(xmod);

for i = 1 : N_cycles
    ys_cur = y_s{i};    xs_cur = x_s{i};
    ys_cur = ys_cur(:,2); xs_cur = xs_cur(:,2);
    xpos = xs_cur >= s_info.x_mean; xs_cur(xpos) = s_info.x_mean + s_info.x_mod;
    ypos = ys_cur >= s_info.y_mean; ys_cur(ypos) = s_info.y_mean + s_info.y_mod;
    xneg = xs_cur < s_info.x_mean; xs_cur(xneg) = s_info.x_mean - s_info.x_mod;
    yneg = ys_cur < s_info.y_mean; ys_cur(yneg) = s_info.y_mean - s_info.y_mod;
    ys_cur2 = y_s{i}; ys_slice{i} = [ys_cur2(:,1) ys_cur ys_cur2(:,3)];
    xs_cur2 = x_s{i}; xs_slice{i} = [xs_cur2(:,1) xs_cur xs_cur2(:,3)];
end
switched.ys_slice = ys_slice;
switched.xs_slice = xs_slice;
end