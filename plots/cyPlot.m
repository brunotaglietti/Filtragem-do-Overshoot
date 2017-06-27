%% Single Cycle Ploting Function
% Function which results the plot of a single cycle. The necessary inputs are the original
% signal (for the off-switch part), the fragmented switched signal, the signal information
% in s_info, the filters outputs yout, and the particular cycle to plot.

function cyPlot(signal, switched, s_info, yout, n, errors)
%% Loading and preparing data
global fignum;
y = switched.y{n};
ys = switched.y_s{n};
ydd = switched.ys_slice{n};
xdd = (switched.xs_slice{n} - s_info.x_mean)/s_info.x_mod*s_info.y_mod + s_info.y_mean;
errors_1 = errors.s{n};
e_c = yout.e{n};   ew_c = yout.ew{n}; erls_c = yout.erls{n};
y_sec = (y(:,2) - s_info.y_mean)/s_info.y_mod;
ys_sec = (ys(:,2) - s_info.y_mean)/s_info.y_mod;
range = s_info.t_wholeCy{n}; L = length(range);
range = range(round(L/5):round(L*4/5));
section = length(yout.w{n});
t_s = 1e6*y(ys(1:section,3),1);
%% Plot including off-switch signal
eval([sprintf('fig%i',fignum) ' = anotherfig;'])
set(gca, 'FontName', 'Times New Roman','FontSize',12)

plot(signal.t(range,1), signal.y(range,1), 'color', ([.1 .6 .2]+3)/4), hold on;
plot(signal.t(range,2),signal.y(range,2),'Color',.9*ones(1,3))
xlim(signal.t([min(range), max(range)],2))
plot(y(:,1), y(:,2),'color',.4*ones(1,3))
plot(y(ys(1:end-2,3),1), ys(1:end-2,2),'k.')
plot(y(ys(1:end-2,3),1), ydd(1:end-2,2),'.', 'color',[.3 .4 1])
plot(y(ys(1:end-2,3),1), xdd(1:end-2,2),'o', 'color',[.3 .6 .4])
if exist('errors','var')
    plot(y(ys(find(errors_1),3),1),ydd(find(errors_1),2),'r.','markersize',10)
end
x_axis=get(gca,'xlim'); y_axis = get(gca,'ylim');
plot(x_axis, s_info.y_mean*[1 1],'--','color',.8*ones(1,3))
plot(x_axis, s_info.y_mean - s_info.y_mod*[1 1],'--','color',.8*ones(1,3))
plot(x_axis, s_info.y_mean + s_info.y_mod*[1 1],'--','color',.8*ones(1,3))
plot(y(ys(1,3),1)*[1 1], y_axis, '--', 'color', .8*[1 1 1]);
plot(y(ys(section,3),1)*[1 1], y_axis,'--', 'color', .8*[1 1 1]);
xlabel('Time (s)'), ylabel('Step (V)')
legend('Electrical Reference', 'Off-switch', 'On-switch', 'Samples', 'Decision Driven', 'Sliced Electrical Samples')
%% Plot focused in the filter output and error
eval([sprintf('fig%i',fignum) ' = anotherfig;'])
set(fignum-1,'windowstyle','normal', 'Position', [100, 100, 550, 550])
set(gca, 'FontName', 'Times New Roman','FontSize',12)
fig_prop = {'linewidth', 2, 'markersize', 10};
subplot(3,1,[1, 2]);

plot(1e6*y(1:ys(section,3),1), y_sec(1:ys(section,3)),'color',.6*ones(1,3)); hold on
h1 = plot(t_s, (ydd(1:section,2)-s_info.y_mean)/s_info.y_mod,'.', 'color', .7*[1 1 1]);
h2 = plot(t_s, (xdd(1:section,2)-s_info.y_mean)/s_info.y_mod,'o', 'color', .7*[1 1 1]);
h3 = plot(t_s, ys_sec(1:section),'.', 'color', .4*ones(1,3), 'markersize', 14);
h4 = plot(t_s, yout.rls{n}, 'x', 'Color', [71 203 44]/255, fig_prop{:});
h5 = plot(t_s, yout.w{n}, '+', 'Color', [72, 133, 237]/255, fig_prop{:}); drawnow;
x_axis = get(gca, 'xlim');
plot(x_axis, [1 1], '--', x_axis, -[1 1], '--', x_axis, [0 0], '--', 'color', .9*ones(1,3)); drawnow;
xlim([min(t_s) max(t_s)]); ylim([min(y_sec(1:ys(section,3))), max(y_sec(1:ys(section,3)))]);
xlabel('Time (µs)'); ylabel('Signals');
legend([h1 h2 h3 h4 h5], 'Decision driven', 'Electrical reference', 'Original samples',...
    'RLS', 'Wiener filter');
set(gca, 'FontName', 'Times New Roman','FontSize',12);

subplot 313; hold on;
plot(t_s, e_c(1:section), '.-', 'color', .4*ones(1,3), fig_prop{:});
plot(t_s, erls_c(1:section), 'x-', 'Color', [71 203 44]/255, fig_prop{:});
plot(t_s, ew_c(1:section), '+-', 'Color', [72, 133, 237]/255, fig_prop{:});
xlim([min(t_s) max(t_s)]);
% ylim([0 1.1])
ylabel('e^2'); xlabel('Time (µs)'); 
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
end