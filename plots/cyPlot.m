%% Single Cycle Ploting Function
% Function which results the plot of a single cycle. The necessary inputs are the original
% signal (for the off-switch part), the fragmented switched signal, the signal information
% in s_info, the filters outputs yout, and the particular cycle to plot.

function cyPlot(signal, switched, s_info, yout, n, errors, filters)
fprintf('Cycle plot.\n');
%% Original Signal Emphasized
if ~exist('filters', 'var'), filters = 1:4; end;
pConf = {'-', 'color', .4*[1 1 1];...
        '.', 'color', [0 0 0];...
        '.', 'color', [.3 .4 1];...
        'o', 'color', [.3 .6 .4]}; i = 1;
f1 = figure;
if exist('signal','var')
    range = s_info.t_wholeCy{n};
    L = length(range);
    range = range(round(L/5):round(L*4/5));
    plot(signal.t(range,1), signal.y(range,1), 'color', ([.1 .6 .2]+3)/4), hold on;
    plot(signal.t(range,2),signal.y(range,2),'Color',.9*ones(1,3))
    x_axis = signal.t(range([1 end]));
end
plot(switched.Norm.y{n}(:,1),switched.Norm.y{n}(:,2), 'color', [.9 .5 .6]), hold on
if ~exist('signal','var'), x_axis = switched.y{n}([1 end],1); end
eF = fieldnames(switched);
for k = [1 2 6 7]
    t = switched.(eF{k}){n}(:,1); y = switched.(eF{k}){n}(:,2);
    if k == 7
        y = (y - s_info.x_mean)/s_info.x_mod*s_info.y_mod + s_info.y_mean;
    end
    plot(t, y, pConf{i,:}), i = i + 1;
end
if exist('errors','var')
    plot(switched.y_s{n}(find(errors{1}.s{n}),1),...
        switched.y_s{n}(find(errors{1}.s{n}),2),'rx', 'linewidth', 1.5);
end

y_axis = 3*s_info.y_mod*[-1 1] + s_info.y_mean;

plot(x_axis, s_info.y_mean*[1 1],'--','color',.8*ones(1,3))
plot(x_axis, s_info.y_mean - s_info.y_mod*[1 1],'--','color',.8*ones(1,3))
plot(x_axis, s_info.y_mean + s_info.y_mod*[1 1],'--','color',.8*ones(1,3))
plot(switched.y_s{n}(1,1)*[1 1], y_axis, '--', 'color', .8*[1 1 1]);
plot(switched.y_s{n}(end,1)*[1 1], y_axis, '--', 'color', .8*[1 1 1]);
xlabel('Time (s)'), ylabel('Step (V)'), xlim(x_axis), ylim(y_axis);
cont = {'Generetor reference', 'PD output', 'Normalization', 'Switch on',...
        'Sampled signal', 'Sliced samples', 'Reference samples'};
legend(cont)
%% Filters Emphasis
f2 = figure('windowstyle', 'normal', 'Position', [100, 100, 550, 550]);
fig_prop = {'linewidth', 1.5, 'markersize', 8};
subplot(3,1,[1, 2]);
plot(switched.y{n}(:,1),(switched.y{n}(:,2) - s_info.y_mean)/s_info.y_mod,...
    'color',.6*ones(1,3)); hold on
x_axis = [switched.y{n}(1,1), switched.y{n}(end,1)];
clear pConf; pConf = {'.', 'color', .4*[1 1 1], fig_prop{:};...
                      '.', 'color', .7*[1 1 1], fig_prop{:};...
                      'o', 'color', .7*[1 1 1], fig_prop{:}}; i=1;

for k = [2 6 7]
    t = switched.(eF{k}){n}(:,1);
    if k == 7, y = (switched.(eF{k}){n}(:,2) - s_info.x_mean)/s_info.x_mod;
    else, y = (switched.(eF{k}){n}(:,2) - s_info.y_mean)/s_info.y_mod;
    end
    plot(t, y, pConf{i,:}); i=i+1;
end
ts = switched.(eF{2}){n}(:,1);
yF = fieldnames(yout);
ax = gca; ax.ColorOrderIndex = 1;
for k = filters
    ys = yout.(yF{k}){n};
    plot(ts, ys, '.', fig_prop{:})
end
if exist('errors','var')
t = switched.y_s{n}(find(errors{1}.s{n}),1);
y = (switched.y_s{n}(find(errors{1}.s{n}),2) - s_info.y_mean)/s_info.y_mod;
plot(t, y,'x', fig_prop{:}, 'color', .4*[1 1 1]);
ax = gca; ax.ColorOrderIndex = 1;
for k = filters
    et = ts(find(errors{1}.(yF{k}){n}));
    es = yout.(yF{k}){n}(find(errors{1}.(yF{k}){n}));
    plot(et, es, 'x', fig_prop{:})
end
end
cont2 = {'PD output', 'Samples', 'Sliced samples', 'Reference', yF{filters}};
legend(cont2)
ylabel('Signals'), set(gca,'xticklabel',[]), xlim(x_axis), grid on

subplot(3,1,3)
for k = filters + 4
    plot(ts,yout.(yF{k}){n},'-'), hold on
end
legend(yF{filters + 4}), ylabel('e^2'), xlabel('Time (s)'), xlim(x_axis), grid on