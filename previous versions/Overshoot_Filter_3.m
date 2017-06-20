%% Filtragem de Overshoot de Chaveamento
% Amplificadores �pticos a Semicondutores apresentam _overshoot_ e
% oscila��es transientes quando utilizados como Chaves eletro-�pticas. Este
    % projeto analiza a influ�ncia de filtros �timos e adaptativos no tempo de
% subida e estabiliza��o de SOAs. Caso haja sucesso, a filtragem ir�
% diminuir o tempo de chaveamento trazendo maior estabilidade, maior
% efici�ncia energ�tica, maior velocidade e desempenho.
clc; close all; clear all; tic;
root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
addpath([root_dir 'MatLab/'], [root_dir 'chav-amo-SOA-prbs'], 'functions');
%% Leitura da Medi��o

SOA = 'CIP-L';  % SOA used on the measures
% SOA = 'InPhenix-1503';

tim = 0.32;                     % pre-impulse duration (ns) / pisic 4 => 0.32
imp = 0.5;                      % pre-impulse voltage
deg = 0.5;                      % step voltage
cur = 0.06;                     % bias current
parameters.var = [tim, imp, deg, cur];
parameters.tech = 'pisic';      % t�cnica de pr�-impulso e, se for, PRBS
parameters.bitstream = 'prbs';  % para PRBS => 'prbs'; para sqrwv => '';

signal = switch_file_import(SOA, parameters);
y = signal.y;   t = signal.t;   yf = signal.yf; y_unb = signal.y_unb;
clear tim imp deg cur tech

pulselength = 8e-9; ts = t(2) - t(1);      % Tempo de amostragem
fmod = 6.985e9;     % Freq. modula��o (est. inicial)
samples = round(pulselength*2/ts); % n�mero de amostras durante um ciclo de chaveamento.
spbit = round(1/fmod/(t(2)-t(1))); % Samples per bit. N�mero de amostras por s�mbolo modulado.

%% Segmenta��o e amostragem dos Ciclos de Chaveamento
% Cada ciclo de chaveamento deve ser isolado para processamento individual,
% para que se evite a acumula��o de estat�sticas inv�lidas para o chaveamento usual.
%
% O ponto _riseedge_ representa a borda de subida da chave, e � encontrado
% utilizando o n�vel de subida definido anteriormente em _rise thresh_. A
% borda de descida � determinada de forma similar. No gr�fico, a se��o da
% curva mais escura denota o per�odo do qual o sinal encontra-se chaveado.
%
% Antes de entrar no _loop_ de itera��es, define-se o n�mero total de
% ciclos de chaveamento, segmenta-se  o primeiro intervalo e prepara-se a
% representa��o gr�fica para sua atualiza��o iterativa.
% 
% Ap�s a defini��o dos pontos de fechamento e abertura da chave, � feita a
% amostragem do sinal, guardando os pontos amostrados em um novo vetor, que
% ser� utilizado nas se��es seguintes. No gr�fico, os pontos amostrados s�o
% apresentados em forma de pequenos c�rculos.

y_avg = zeros(samples,1);
N_cycles = floor(length(y) / samples);
for n = 1:N_cycles, range = (n - 1)*samples + 1 : samples * n;
    y_avg = y_avg + y(range); end
y_avg = y_avg / N_cycles;

rise_thresh = (max(y_avg) - min(y_avg)) / 10*6 + min(y_avg);   % 70% da subida (em y)
fall_thresh = (max(y_avg) - min(y_avg)) / 10*2 + min(y_avg);   % 30% da subida

if(y_avg(samples)<rise_thresh)     % Condi��o de chave aberta no ponto _samples_.
    riseedge = find(y_avg>rise_thresh,1,'first');
    falledge = find(y_avg(riseedge:end)<fall_thresh,1,'first')+riseedge;
else    % Condi��o de chave fechada no ponto _samples_.
    falledge = find(y_avg<fall_thresh,1,'first');
    riseedge = find(y_avg(falledge:end)>rise_thresh,1,'first')+falledge;
end

% Intervalo do primeiro ciclo de chaveamento

interv1 = riseedge - round(samples/4);
if interv1 < 1
    interv1 = falledge + round(samples/4);
    riseedge = riseedge + samples - 1; falledge = falledge + samples - 1;
end
interv2 = interv1 + samples - 1; i12 = interv1:interv2;
sw_t = (riseedge:falledge);


N_cycles = floor(length(y(interv1:end)) / samples/2); % Numero de ciclos de chaveamento
Ns_cy = zeros(N_cycles,1);
y_avg = [y_avg; y_avg];     y_avg = y_avg(i12);



% Aloca��o de mem�ria
y_cycle = cell(N_cycles,1);     y_cycle{1} = y(i12);            y_cur = y(sw_t);
yf_cycle = cell(N_cycles,1);    yf_cycle{1} = yf(i12);          yf_cur = yf(sw_t);
yub_cycle = cell(N_cycles,1);   yub_cycle{1} = y_unb(i12);      yub_cur = y_unb(sw_t);
ys_c = cell(N_cycles, 1);
hsm = zeros(length(i12),1);
tcur = t(sw_t);

set(0,'DefaultFigureWindowStyle','docked')
fig(1) = figure('name','Amostragem');
h1 = plot(t(i12),y_cycle{1},'Color',[.7,.7,1]); hold on;
h2 = plot(t(i12),yf_cycle{1},'Color',[1,.7,.7]);
h3 = plot(t(i12),yub_cycle{1},'Color',[.7,1,.7]);
h4 = plot(tcur,y_cur,'--'); set(h4,'Color','b','LineWidth',2)
h5 = plot(tcur,yf_cur,'--'); set(h5,'Color','r','LineWidth',2)
h6 = plot(tcur,yub_cur,'--'); set(h6,'Color',[0, .9, 0],'LineWidth',2)
h7 = plot(1:length(hsm),hsm,'ko');
xlim([t(interv1) t(interv2)]), ylim([min(y) max(y)]); xlabel('t (s)'), ylabel('S (V)')
legend([h4 h5 h6 h7],'Original','Filtrado','Subtra��o','Amostras')
title('Segmenta��o e Amostragem');

clear rise_thresh fall_thresh

%% _Loop_ de itera��es para segmenta��o e apresenta��o.
for i = 1 : N_cycles - 1
    interval =  ((i-1)*samples : (i)*samples - 1) + interv1;
    y_cur = y(interval);        yf_cur = yf(interval);      yub_cur = y_unb(interval);
    
    sw_t = sw_t + samples;
    y_cycle{i} = y(sw_t);       yf_cycle{i} = yf(sw_t);     yub_cycle{i} = y_unb(sw_t);
    
    P = sampling(y_cycle{i},tcur);
    ys_c{i} = [tcur(P), y(sw_t(P))];
    Ns_cy(i) = length(P);
    
    plot_update(h1,y_cur,...
        h2,yf_cur,...
        h3,yub_cur,...
        h4, y_cycle{i},...
        h5, yf_cycle{i},...
        h6, yub_cycle{i},...
        h7, ys_c{i})
    drawnow
%     pause(1);
end

clear interv1 start_interv end_interv interval interv2 interv12 handle1 handle2 falledge...
    riseedge i12 tcrop tcrop_cur y_cur yf_cur yub_cur sw_t hsm p_hsm y_s t_s sw_t


%% Filtragem de Wiener
% Nesta se��o, utilizam-se os pontos amostrados na se��o anterior numa
% abordagem cl�ssica de filtragem de sinais digitais. As vari�veis
% utilizadas s�o o sinal amostrado original e a decis�o (valor esperado).
% Com isso, � feita a filtragem de Wiener utilizando a estat�stica de cada
% semic�clo de chaveamento.
% 
% O primeiro gr�fico apresentado mostra os valores discretos das amostras originais, a decis�o, e o
% valor ap�s a filtragem. O segundo gr�fico encontra o erro sem, e com a
% utiliza��o do filtro de Wiener.
% 
% � poss�vel observar que, ap�s a estabiliza��o do _overshoot_, o erro
% utilizando o filtro �timo � aceit�vel. Entretanto, durante as oscila��es
% do _overshoot_ o filtro provoca erro ainda maior.
% 
% O filtro de Wiener utiliza as estat�sticas presentes no sinal para
% compensar efeitos lineares do canal te�rico, e ru�do gaussiano. Por�m, o
% _overshoot_ n�o pode ser representado nem como uma convolu��o linear, nem
% como ru�do gaussiano, portanto o resultado do filtro n�o � satisfat�rio.


x = cell(N_cycles,1);
yw = cell(N_cycles,1); yw{1} = zeros(length(x{1}),1);
x_c = ys_c{1}; x{1} = x_c(:,2); 
d = cell(N_cycles,1); d{1} = ones(length(x{1}),1);
e = cell(N_cycles,1); e{1} = zeros(length(ys_c{1}),1);
ew = cell(N_cycles,1); ew{1} = zeros(length(ys_c{1}),1);
e_avg = zeros(N_cycles,1); ew_avg = zeros(N_cycles,1);

fig(2) = figure('name','Filtragem de Wiener'); subplot(3,1,[1 2]);
h1 = stem(x{1},'b'); hold all; set(h1,'MarkerFaceColor',[0.5,0.5,1]);
h2 = stem(d{1},'r','.');
h3 = stem(yw{1},'Color',[0.3, 0.8, 0.3]); set(h3,'MarkerFaceColor',[0.5,1,0.5]);
legend([h1, h2, h3], 'Original', 'Decis�o', 'Filtrado');
xlim([0, 55]), ylim([-2.5, 2.5]), title('Solu��o de Wiener'); hold off;

subplot(3,1,3), h4 = stem(e{1}); hold all; set(h4,'MarkerFaceColor',[0.5,0.5,1]);
h5 = stem(ew{1}); set(h5,'MarkerFaceColor',[0.5,1,0.5]);
legend([h4 h5], 'S/ filtro','C/ filtro');
xlim([0 55]), ylim([-0.1, 2]); title('Erro');

M = 3;
Wo = zeros(N_cycles,M);
for k = 1:N_cycles-1
    x_c = ys_c{k}; x_c = x_c(:,2) - mean(x_c(:,2));
    coef = mean(abs(x_c)); x{k} = x_c/coef;
    d_c = ones(length(x{k}),1);
    if x_c(1) < 0, d_c(1:2:end) = -d_c(1:2:end); d{k} = d_c;
    else d_c(2:2:end) = -d_c(2:2:end); d{k} = d_c; end
    
    Wo(k,:) = WStoc(x{k},d{k},M); yw{k} = filter(Wo(k,:),1,x{k});
    e{k} = abs(d{k} - x{k}); e_avg(k) = sum(e{k})/Ns_cy(k);
    ew{k} = abs(d{k} - yw{k}); ew_avg(k) = sum(ew{k})/Ns_cy(k);
    plot_update(h1,x{k},h2,d{k},h3,yw{k},h4,e{k},h5,ew{k}); drawnow;
end
clear x_c coef d_c

%% Filtragem Adaptativa RLS
% Ao contr�rio da filtragem de Wiener, o filtro adaptativo n�o utiliza as
% estat�sticas de todas as amostras dispon�veis para gerar os coeficientes
% do filtro. Ele considera apenas o erro instant�neo, al�m de seus pr�prios
% par�metros. Consequ�ntemente, ele consegue se adaptar as oscila��es
% causadas pelo _overshoot_ com relativa velocidade, diminuindo o erro.
% 
% A primeira amostra, ap�s o fechamento da chave, erra relativamente
% bastante, por�m, a partir da segunda amostra, o erro j� � diminu�do
% expressivamente.
% 
% Ao fim da an�lise, � mostrado graficamente o desenvolvimento dos
% coeficientes do filtro ao decorrer das amostras. O par�metro \lambda de
% esquecimento do algoritmo utilizado � de 0.9. � poss�vel tirar algumas 
% conclus�es desse gr�fico.
% 
% Primeiramente, � poss�vel observar que nenhum coeficiente se estabiliza.
% Eles ficam se adaptando durante todo o processo. Provavelmente, isso se
% deve a compensa��o dos efeitos din�micos do chaveamento, como o
% _overshoot_. Em seguida, � poss�vel observar que h� um _flip flop_ no
% sinal dos coeficientes. Os coeficientes �mpares s�o positivos, e os pares
% s�o negativos. Isso se deve ao fato de estarmos utilizando o sinal
% modulado quadrado (1, -1, 1, -1...). O sinal PRBS provavelmente
% demonstrar� desempenho diferente.


Wrls = cell(N_cycles,1); Wrls{1} = zeros(M,length(x{1}));
erls = cell(N_cycles,1); erls{1} = zeros(length(x{1}),1);
yrls = cell(N_cycles,1); yrls{1} = zeros(length(x{1}),1);
Wrls_cur = zeros(M,1);
erls_avg = zeros(N_cycles,1);

fig(3) = figure('name','Filtro Adaptativo RLS'); subplot(3,1,[1 2]);
h1 = stem(x{1},'b'); hold all; set(h1,'MarkerFaceColor',[0.5,0.5,1]);
h2 = stem(d{1},'r','.');
h3 = stem(yrls{1},'Color',[0.3, 0.8, 0.3]); set(h3,'MarkerFaceColor',[0.5,1,0.5]);
legend([h1, h2, h3], 'Original', 'Decis�o', 'Filtrado');
xlim([0, 55]), ylim([-2.5, 2.5]), title('Filtro Adaptativo RLS'); hold off;
subplot(3,1,3), h4 = stem(e{1}); hold all; set(h4,'MarkerFaceColor',[0.5,0.5,1]);
h5 = stem(erls{1}); set(h5,'MarkerFaceColor',[0.5,1,0.5]);
legend([h4 h5], 'S/ filtro','C/ filtro');
xlim([0 55]), ylim([-0.1, 2]); title('Erro');
for k = 1:N_cycles-1
    [Wrls{k}, e_c, yrls{k}] = algRLS(x{k},d{k},Wrls_cur); erls{k} = abs(e_c);
    erls_avg(k) = sum(e_c)/Ns_cy(k);
    Wrls_cur = Wrls{k}; Wrls_cur = Wrls_cur(:,end);
    plot_update(h1,x{k},h2,d{k},h3,yrls{k},h4,e{k},h5,erls{k}); drawnow;
end

fig(4) = figure('name','RLS - Desenvolvimento dos Coeficientes'); leg_m = cell(M,1);
Wrls_rec = zeros(M,sum(Ns_cy));
for m = 1:M
    for n = 1:N_cycles-1
        W_cur = Wrls{n}; W_cur = W_cur(m,:);
        t2 = sum(Ns_cy(1:n)) + 1; t1 = t2 - Ns_cy(n);
        Wrls_rec(m,t1:t2) = W_cur;
    end
    range = 1:sum(Ns_cy);
    plot(range,Wrls_rec(m,range),'LineWidth',1.2,'Color',.1+.9*rand(1,3)), hold on;
    leg_m{m} = [num2str(m) '^o coeficiente'];
end
title('Desenvolvimento dos coeficientes do algoritmo RLS');
xlabel('Amostras'); ylabel('Valor do Coeficiente');
legend(leg_m),xlim([1 sum(Ns_cy)])
clear Wrls_cur leg_m e_c h1 h2 h3 h4 h5 h6 h7 hleg hleg2 t1 t2 leg_m n k i m

%% Erro Resultante das Abordagens
% Por fim, apresentam-se os erros resultantes sem a utiliza��o de filtro
% algum, utilizando o filtro �timo de Wiener, e com o filtro adaptativo
% RLS.
% 
% Observa-se que sem utiliza��o de filtro algum, apresenta erro menor do
% que a utiliza��o do filtro �timo de Wiener. Isso est� explicado na se��o
% do mesmo. Entretanto, o filtro adaptativo RLS apresenta erro total 165 vezes
% menor.

e_t = (sum([e_avg, ew_avg, erls_avg])/N_cycles).^2;
fprintf(['\nErro m�dio quadr�tico sem filtragem:\t\t\t%f\n',...
    'Erro m�dio quadr�tico com filtro de Wiener:\t\t%f\n',...
    'Erro m�dio quadr�tico com filtro RLS:\t\t\t%f\n\n'],e_t);
toc