%% Single Cycle Ploting Function
% Function which results the plot of a single cycle. The necessary inputs are the original
% signal (for the off-switch part), the fragmented switched signal, the signal information
% in s_info, the filters outputs yout, and the particular cycle to plot.

function cyPlot(signal, switched, s_info, yout, n, errors)
fprintf('Cycle plot.\n');
%% Loading and preparing data
global fignum;
y = switched.y{n};
ys = switched.y_s{n};
yN = switched.Norm.y{n}; yNs = switched.Norm.y_s{n};
ydd = switched.ys_slice{n};
xdd = (switched.xs_slice{n} - s_info.x_mean)/s_info.x_mod*s_info.y_mod + s_info.y_mean;
if exist('errors','var'), errors_1 = errors{1}.s{n}; end
e_c = yout.e{n};   ew_c = yout.ew{n}; erls_c = yout.erls{n};
y_sec = (y(:,2) - s_info.y_mean)/s_info.y_mod;
ys_sec = (ys(:,2) - s_info.y_mean)/s_info.y_mod;
range = s_info.t_wholeCy{n}; L = length(range);
range = range(round(L/5):round(L*4/5));
section = length(yout.w{n});
t_s = ys(1:section,1);
%% Plot including off-switch signal
% eval([sprintf('fig%i',fignum) ' = anotherfig;'])

if ~exist('figsignal','var'), figsignal = figure; end
set(gca, 'FontName', 'Times New Roman','FontSize',12)

plot(yN(:,1),yN(:,2), 'color', [.9 .5 .6]), hold on;
plot(signal.t(range,1), signal.y(range,1), 'color', ([.1 .6 .2]+3)/4)
plot(signal.t(range,2),signal.y(range,2),'Color',.9*ones(1,3))
xlim(signal.t([min(range), max(range)],2))
plot(y(:,1), y(:,2),'color',.4*ones(1,3))
plot(ys(1:end-2,1), ys(1:end-2,2),'k.')
plot(ys(1:end-2,1), ydd(1:end-2,2),'.', 'color',[.3 .4 1])
plot(ys(1:end-2,1), xdd(1:end-2,2),'o', 'color',[.3 .6 .4])
if exist('errors','var')
    plot(ys(find(errors_1),1),ydd(find(errors_1),2),'r.','markersize',10)
end

x_axis = [signal.t(range(1)) signal.t(range(end))];
y_axis = 3*s_info.y_mod*[-1 1] + s_info.y_mean;

plot(x_axis, s_info.y_mean*[1 1],'--','color',.8*ones(1,3))
plot(x_axis, s_info.y_mean - s_info.y_mod*[1 1],'--','color',.8*ones(1,3))
plot(x_axis, s_info.y_mean + s_info.y_mod*[1 1],'--','color',.8*ones(1,3))
plot(ys(1,1)*[1 1], y_axis, '--', 'color', .8*[1 1 1]);
plot(ys(section,1)*[1 1], y_axis,'--', 'color', .8*[1 1 1]);
xlabel('Time (s)'), ylabel('Step (V)'), xlim(x_axis), ylim(y_axis);
legend('Normalized Signal', 'Electrical Reference', 'Off-switch', 'On-switch',...
    'Samples', 'Decision Driven', 'Sliced Electrical Samples')
hold off;
%% Plot focused in the filter output and error
% eval([sprintf('fig%i',fignum) ' = anotherfig;'])
figfilt = figure;
set(figfilt,'windowstyle','normal', 'Position', [100, 100, 550, 550])
set(gca, 'FontName', 'Times New Roman','FontSize',12)
fig_prop = {'linewidth', 2, 'markersize', 10};
subplot(3,1,[1, 2]);
t_s = 1e6*ys(1:section,1);
plot(1e6*y(:,1), y_sec,'color',.6*ones(1,3)); hold on
h1 = plot(t_s, (ydd(:,2)-s_info.y_mean)/s_info.y_mod,'.', 'color', .7*[1 1 1]);
h2 = plot(t_s, (xdd(:,2)-s_info.y_mean)/s_info.y_mod,'o', 'color', .7*[1 1 1]);
h3 = plot(t_s, ys_sec,'.', 'color', .4*ones(1,3), 'markersize', 14);
h4 = plot(t_s, yout.rls{n}, 'x', 'Color', [71 203 44]/255, fig_prop{:});
h5 = plot(t_s, yout.w{n}, '+', 'Color', [72, 133, 237]/255, fig_prop{:}); drawnow;
x_axis = get(gca, 'xlim');
plot(x_axis, [1 1], '--', x_axis, -[1 1], '--', x_axis, [0 0],...
    '--', 'color', .9*ones(1,3)); drawnow;
xlim([min(t_s) max(t_s)]); ylim([min(y_sec), max(y_sec)]);
xlabel('Time (µs)'); ylabel('Signals');
legend([h1 h2 h3 h4 h5], 'Decision driven', 'Electrical reference', 'Original samples',...
    'RLS', 'Wiener filter');
set(gca, 'FontName', 'Times New Roman','FontSize',12);

subplot 313; hold on;
plot(t_s, e_c, '.-', 'color', .4*ones(1,3), fig_prop{:});
plot(t_s, erls_c, 'x-', 'Color', [71 203 44]/255, fig_prop{:});
plot(t_s, ew_c, '+-', 'Color', [72, 133, 237]/255, fig_prop{:});
xlim([min(t_s) max(t_s)]);
% ylim([0 1.1])
ylabel('e^2'); xlabel('Time (µs)'); 
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
end