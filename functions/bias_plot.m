%% Caracterização em relação a Corrente
% Função que plota resultados em relação a corrente de polarização do SOA.

function bias_plot(bias_r, mse_char, char_title)
if ~exist('char_title','var'), char_title = 'Mean Squared Error'; end;
global fignum;
eval([sprintf('fig%i',fignum) ' = anotherfig;'])
set(fignum-1,'windowstyle','normal', 'Position', [100, 100, 450, 300])
fig_prop = {'.-','linewidth',1,'markersize',10};

h1 = plot(bias_r, [mse_char.s], fig_prop{:}); hold on;
h2 = plot(bias_r, [mse_char.w], fig_prop{:});
h3 = plot(bias_r, [mse_char.w2], fig_prop{:});
h4 = plot(bias_r, [mse_char.rls], fig_prop{:});
h5 = plot(bias_r, [mse_char.rls2], fig_prop{:});
% h6 = plot(bias_r, [mse_char.rls_i], fig_prop{:});
xlim([bias_r(1) bias_r(end)]); ylim([0 max([mse_char.s])]);

fit1 = fit(bias_r',[mse_char.s]', 'poly2');
fit2 = fit(bias_r',[mse_char.w]', 'poly2');
fit3 = fit(bias_r',[mse_char.w2]', 'poly2');
fit4 = fit(bias_r',[mse_char.rls]', 'poly2');
fit5 = fit(bias_r',[mse_char.rls2]', 'poly2');
% fit6 = fit(bias_r',[mse_char.rls_i]', 'poly2');

f1p = plot(fit1); set(f1p, 'Color', (get(h1, 'color')+1)/2, 'LineStyle', '--')
f2p = plot(fit2); set(f2p, 'Color', (get(h2, 'color')+1)/2, 'LineStyle', '--')
f3p = plot(fit3); set(f3p, 'Color', (get(h3, 'color')+1)/2, 'LineStyle', '--')
f4p = plot(fit4); set(f4p, 'Color', (get(h4, 'color')+1)/2, 'LineStyle', '--')
f5p = plot(fit5); set(f5p, 'Color', (get(h5, 'Color')+1)/2, 'LineStyle', '--')
% f6p = plot(fit6); set(f6p, 'Color', (get(h6, 'Color')+1)/2, 'LineStyle', '--')

curves = {'Unfiltered', 'Wiener filter', 'Wiener filter - 3 taps', 'RLS',...
    'RLS - 3 taps'};
%     'RLS - 3 taps', 'RLS - identity'};
legend(curves);
xlabel('Bias (A)'), ylabel(char_title);
set(gca, 'FontName', 'Times New Roman','FontSize',12);
set(gca, 'box', 'off');

end