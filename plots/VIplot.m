%% Visualiza��o 3.0
% A visualiza��o 3d � feita para a caracteriza��o de duas vari�veis. Atualmente, est�o
% sendo utilizadas as vari�veis bias_range e deg_range. Ou seja, o gr�fico 3d mostrar� o
% Erro M�dio Quadr�tico resultante em rela��o �s vari�veis corrente de polariza��o, e
% amplitude do degrau. Portanto, essa se��o do script necessita que, no cabe�alho,
% modifique-se deg_range para que varra a regi�o desejada (0.5:0.25:1.5).

function VIplot(bias, deg, mse_char, char_title, c_lim)
global fignum;
curves = {'Unfiltered', 'Wiener filter', 'Wiener filter - 4 taps', 'RLS',...
    'RLS - 4 taps', 'RLS - identity'};

iter_size = 1000;
[X,Y] = meshgrid(bias,deg);
xi = linspace(bias(1), bias(end),iter_size);
yi = linspace(deg(1), deg(end),iter_size);
[XI, YI] = meshgrid(xi,yi);
msefields = fieldnames(mse_char);

for n = 1:length(msefields)
    cur_field = msefields{n};
    mse_i = reshape([mse_char.(cur_field)],[length(deg), length(bias)]);
    if strcmp(char_title,'BER'), mse_i = log10(mse_i); end
    mse_xy = interp2(X,Y,mse_i,XI,YI);
    
    eval([sprintf('fig%i',fignum) ' = anotherfig;'])
    set(fignum-1,'windowstyle','normal', 'Position', [100, 200, 450, 300])
    contourf(XI,YI,mse_xy,35,'EdgeColor','none','LineStyle','none'), hold on;
    plot(X(:),Y(:),'.','Color','k','MarkerSize',5);
    xlim([min(bias) max(bias)]);
    ylim([min(deg) max(deg)]);
    if exist('c_lim','var'), caxis(c_lim); end;
    xlabel('Bias (A)'), ylabel('Step (V)'), zlabel(char_title)
    title(curves{n});
    c = colorbar;  % ylabel(c,'Mean Squared Error');
    if strcmp(char_title,'BER'), ylabel(c,'Bit Error Rate');
    else, ylabel(c,'Mean Squared Error'); end
    set(gca, 'FontName', 'Times New Roman','FontSize',12)
    fprintf([curves{n} ' minimum ' char_title ': \t' num2str(min(mse_i(:))) '\n']);
end