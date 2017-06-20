%% Filtragem de Overshoot de Chaveamento
% Amplificadores Ópticos a Semicondutores apresentam _overshoot_ e
% oscilações transientes quando utilizados como Chaves eletro-ópticas. Este
% projeto analiza a influência de filtros ótimos e adaptativos no tempo de
% subida e estabilização de SOAs. Caso haja sucesso, a filtragem irá
% diminuir o tempo de chaveamento trazendo maior estabilidade, maior
% eficiência energética, maior velocidade e desempenho.

close all; % clear all; tic;
root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
addpath([root_dir 'MatLab/'], [root_dir 'chav-amo-SOA-prbs'], 'functions', 'plots');
clear root_dir;

%% Leitura da Medição

SOA = 'CIP-NL';  % SOA used on the measures
% SOA = 'InPhenix-1503';

% deg_range = 0.5:0.25:1.5;
% imp_range = [.5, .5, 1, 1, 1.5];
bias_range = 0.03:0.005:0.07;
deg_range = 1.5;
imp_range = 1.5;
% bias_range = 0.030;

ems_s = zeros(length(deg_range),length(bias_range));
ems_w = ems_s; ems_w2 = ems_s;
ems_rls = ems_s;    ems_rls_i = ems_s;  ems_rls2 = ems_s;

%% Characterization
for Vn = 1:length(deg_range)
for In = 1:length(bias_range)
% for tn = 1:length(tim_range);

tim = 0.64;                     % pre-impulse duration (ns) / pisic 4 => 0.32
imp = imp_range(Vn);                      % pre-impulse voltage
deg = deg_range(Vn);                      % step voltage
cur = bias_range(In);                     % bias current

parameters.var = [tim, imp, deg, cur];
parameters.tech = 'misic';      % técnica de pré-impulso e, se for, PRBS
parameters.bitstream = '';      % para PRBS => 'prbs'; para sqrwv => '';

signal = switch_file_import(SOA, parameters);
[switched, s_info] = sw_cycle(signal);

clear tim imp deg cur tech
%% Filtering

M = 2; M2 = 3;
section = 20;
section_rls = 5;

Rx = zeros(s_info.N_cycles,M); Pxd = Rx;
Rrls = Rx; Prls = Rx;

Rx2 = zeros(s_info.N_cycles,M2); Pxd2 = Rx2;
Rrls2 = Rx2; Prls2 = Rx2;

for n = 1:s_info.N_cycles
    ys = switched.y_s{n}; ys = (ys(:,2)-s_info.mean)/s_info.mod;
    ys_dd = switched.ys_dd{n}; ys_dd = (ys_dd(:,2)-s_info.mean)/s_info.mod;
    
    if section > length(ys), section = length(ys); end;
    R = mXcor(ys(1:section), M);    Rx(n,:) = R(1,:);
    R2 = mXcor(ys(1:section), M2);  Rx2(n,:) = R2(1,:);
    
    Rrls_c = mXcor(ys(1:section_rls),M); Rrls(n,:) = Rrls_c(1,:);
    Rrls2_c = mXcor(ys(1:section_rls),M2); Rrls2(n,:) = Rrls2_c(1,:);
    
    Prls(n,:) = mXcor(ys(1:section_rls), ys_dd(1:section_rls), M);
    Prls2(n,:) = mXcor(ys(1:section_rls), ys_dd(1:section_rls), M2);
    Pxd(n,:) = mXcor(ys(1:section), ys_dd(1:section), M);
    Pxd2(n,:) = mXcor(ys(1:section), ys_dd(1:section), M2);
end

Rx = mean(Rx);  Pxd = mean(Pxd);
w = toeplitz(Rx)\Pxd';
Rx2 = mean(Rx2);    Pxd2 = mean(Pxd2);
w2 = toeplitz(Rx2)\Pxd2';
Rrls = mean(Rrls);  Prls = mean(Prls);
wrlsi = toeplitz(Rrls)\Prls';
Rrls2 = mean(Rrls2);    Prls2 = mean(Prls2);
wrlsi2 = toeplitz(Rrls2)\Prls2';

yw = zeros(s_info.N_cycles,section);
yw2 = yw;   yrls = yw;  yrls_i = yw;    yrls2 = yw;
e = zeros(s_info.N_cycles,1);
ew = e; ew2 = e;    erls = e;   erls_i = e;     erls2 = e;
wrls = zeros(M,1); wrls(1) = 1;

for n = 1:s_info.N_cycles
    ys = switched.y_s{n};    ys = (ys(1:section,2)-s_info.mean)/s_info.mod;
    ys_dd = switched.ys_dd{n};  ys_dd = (ys_dd(1:section,2)-s_info.mean)/s_info.mod;
    yw(n,:) = filter(w,1,ys);
    yw2(n,:) = filter(w2,1,ys);
    
    [w_rls, ~, yrls(n,:)] = algRLS(ys,ys_dd,wrls);
    wrls = w_rls(:,end);
    [w_rls_i, ~, yrls_i(n,:)] = algRLS_mod(ys, ys_dd, wrlsi, inv(toeplitz(Rrls)));
    wrls_i = w_rls_i(:,end);
    [w_wrls2, ~, yrls2(n,:)] = algRLS(ys, ys_dd, wrlsi2);
    
    e(n) = mean((ys - ys_dd).^2);
    ew(n) = mean((yw(n,:) - ys_dd').^2);
    ew2(n) = mean((yw2(n,:) - ys_dd').^2);
    erls(n) = mean((yrls(n,:) - ys_dd').^2);
    erls_i(n) = mean((yrls_i(n,:) - ys_dd').^2);
    erls2(n) = mean((yrls2(n,:) - ys_dd').^2);
end

ems_s(Vn,In) = mean(e);
ems_w(Vn,In) = mean(ew);
ems_w2(Vn,In) = mean(ew2);
ems_rls(Vn,In) = mean(erls);
ems_rls_i(Vn,In) = mean(erls_i);
ems_rls2(Vn,In) = mean(erls2);

clear ys ys_dd R R2 Rx Rx2 Pxd Pxd2 e ew ew2 erls erls2 w w_rls wrls n

%% Visualização

% y = switched.y{1}; y1 = y; ys = switched.y_s{1}; ys_dd = switched.ys_dd{1};
% figure('name','Signal');
% h1 = plot(y(:,1), (y(:,2)-s_info.mean)/s_info.mod,'Color',[.75 .75 .75]); hold on;
% h2 = plot(y(ys(:,3),1), (ys(:,2)-s_info.mean)/s_info.mod, 'k.');
% h3 = plot(y(ys(:,3),1), (ys_dd(:,2)-s_info.mean)/s_info.mod,'b.');
% h4 = plot(y(ys(1:section,3),1), yw(1,:), '*', 'Color', [0 .6 0]);
% h5 = plot(y(ys(1:section,3),1), yrls(1,:),'*', 'Color', [0 0 .6]);
% h6 = plot(y(ys(1:section,3),1), yrls2(1,:),'*', 'Color', [.6 0 0]);
% set(0,'DefaultFigureWindowStyle','docked')
% ylim([-2.2 3])
% xlim=get(gca,'xlim');
% plot(xlim, [0 0], ':', 'Color', .8*ones(1,3))
% plot(xlim,[1 1], ':', 'Color', .8*ones(1,3))
% plot(xlim,-[1 1], ':', 'Color', .8*ones(1,3))
% xlabel('Time (s)'), ylabel('Amplitude (V)');
% legend('Original curve', 'Sampling', 'Slicer decision', 'Wiener Filter', 'RLS', 'RLS initiated');
% 
% for n = 1:s_info.N_cycles
%     y = switched.y{n};  ys = switched.y_s{n};    ys_dd = switched.ys_dd{n};
%     plot_update(h1,(y(:,2)-s_info.mean)/s_info.mod,...
%         h2, [y1(ys(:,3),1), (ys(:,2)-s_info.mean)/s_info.mod],...
%         h3, [y1(ys(:,3),1), (ys_dd(:,2)-s_info.mean)/s_info.mod],...
%         h4, [y1(ys(1:section,3),1), yw(n,:)'],...
%         h5, [y1(ys(1:section,3),1), yrls(n,:)'],...
%         h6, [y1(ys(1:section,3),1), yrls2(n,:)']);
%     drawnow; %pause(1);
%     title(sprintf('%.0f^o Ciclo - %.0f (mA)',n,1e3*bias_range(In))); 
% %     waitforbuttonpress;
% end

end
end
% end
bias_range = 2.5*bias_range;
clear h1 h2 h3 h4 h5 n fig y y1 ys ys_dd xlim
%% Visualização 2.0

fig_prop = {'.-','linewidth',2,'markersize',10};
if ishandle(1), close(f_filters); end; f_filters = figure(1);
set(f_filters,'windowstyle','normal', 'Position', [100, 100, 450, 300])
h1 = plot(bias_range, ems_s, fig_prop{:}); hold on;
h2 = plot(bias_range, ems_rls, fig_prop{:});
h3 = plot(bias_range, ems_rls_i, fig_prop{:});
h4 = plot(bias_range, ems_w, fig_prop{:});
h5 = plot(bias_range, ems_w2, fig_prop{:});
h6 = plot(bias_range, ems_rls2, fig_prop{:});
ems_rls2(1) = [];

fit1 = fit(bias_range', ems_s', 'poly2');
fit2 = fit(bias_range', ems_rls', 'poly2');
fit3 = fit(bias_range', ems_rls_i', 'poly2');
fit4 = fit(bias_range', ems_w', 'poly2');
fit5 = fit(bias_range', ems_w2', 'poly2');
fit6 = fit(bias_range(2:end)', ems_rls2', 'poly2');

f1p = plot(fit1); set(f1p, 'Color', (get(h1, 'color')+1)/2, 'LineStyle', '--')
f2p = plot(fit2); set(f2p, 'Color', (get(h2, 'color')+1)/2, 'LineStyle', '--')
f3p = plot(fit3); set(f3p, 'Color', (get(h3, 'color')+1)/2, 'LineStyle', '--')
f4p = plot(fit4); set(f4p, 'Color', (get(h4, 'color')+1)/2, 'LineStyle', '--')
f5p = plot(fit5); set(f5p, 'Color', (get(h5, 'Color')+1)/2, 'LineStyle', '--')
f6p = plot(fit6); set(f6p, 'Color', (get(h6, 'Color')+1)/2, 'LineStyle', '--')

xlabel('Bias (A)'), ylabel('Mean Squared Error');
clear xlim, xlim([min(bias_range) max(bias_range)])
ylim([0 max(ems_s)]);
legs = {'Original Samples', 'RLS - Identity', 'RLS', 'Wiener Filter',...
    'Wiener Filter - 3 taps', 'RLS - 3 taps'};
legend(legs);
set(gca, 'FontName', 'Times New Roman','FontSize',12);
set(gca, 'box', 'off');

%% Visualização 3.0
% A visualização 3d é feita para a caracterização de duas variáveis. Atualmente, estão
% sendo utilizadas as variáveis bias_range e deg_range. Ou seja, o gráfico 3d mostrará o
% Erro Médio Quadrático resultante em relação às variáveis corrente de polarização, e
% amplitude do degrau. Portanto, essa seção do script necessita que, no cabeçalho,
% modifique-se deg_range para que varra a região desejada (0.5:0.25:1.5).

% close all
% mse = {ems_s, ems_rls, ems_w, ems_w2, ems_rls2};
% ems_case = {'Unfiltered', 'RLS', 'Wiener', 'Wiener - 3 taps', 'RLS - 3 taps'};
% 
% iter_size = 1000;
% [X,Y] = meshgrid(bias_range,deg_range);
% xi = linspace(bias_range(1), bias_range(end),iter_size);
% yi = linspace(deg_range(1), deg_range(end),iter_size);
% [XI, YI] = meshgrid(xi,yi);
% 
% disp(['Number of taps: ' num2str(M)]);
% for n = 1:length(mse)
%     ems_i = interp2(X,Y,mse{n},XI,YI);
%     eval(sprintf('fig%.0f = figure(n);',n));
%     contourf(XI,YI,ems_i,35,'EdgeColor','none','LineStyle','none'), hold on;
%     plot(X(:),Y(:),'.','Color','k','MarkerSize',5);
%     xlim([min(bias_range) max(bias_range)]);
%     ylim([min(deg_range) max(deg_range)]);
%     caxis([0.05 .4]);
%     xlabel('Bias (A)'), ylabel('Step (V)'), zlabel('Mean Squared Error')
%     title(ems_case{n});
%     c = colorbar;   ylabel(c,'Mean Squared Error');
%     set(gca, 'FontName', 'Times New Roman','FontSize',12)
%     mse_c = mse{n};
%     disp([ems_case{n} ' minimum MSE: ' num2str(min(mse_c(:)))]);
% end
