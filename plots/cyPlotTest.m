n=50;
pConf = {'-', 'color', .4*[1 1 1];...
        '.', 'color', [0 0 0];...
        '.', 'color', [.3 .4 1];...
        'o', 'color', [.3 .6 .4]}; i = 1;
range = s_info.t_wholeCy{n}; L = length(range);
range = range(round(L/5):round(L*4/5));

close all; figure;
plot(signal.t(range,1), signal.y(range,1), 'color', ([.1 .6 .2]+3)/4), hold on;
plot(signal.t(range,2),signal.y(range,2),'Color',.9*ones(1,3))
plot(switched.Norm.y{n}(:,1),switched.Norm.y{n}(:,2), 'color', [.9 .5 .6])
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
        switched.ys_slice{n}(find(errors{1}.s{n}),1),'rx', 'linewidth', 1.5);
end

x_axis = [signal.t(range(1)) signal.t(range(end))];
y_axis = 3*s_info.y_mod*[-1 1] + s_info.y_mean;

plot(x_axis, s_info.y_mean*[1 1],'--','color',.8*ones(1,3))
plot(x_axis, s_info.y_mean - s_info.y_mod*[1 1],'--','color',.8*ones(1,3))
plot(x_axis, s_info.y_mean + s_info.y_mod*[1 1],'--','color',.8*ones(1,3))
plot(switched.y_s{n}(1,1)*[1 1], y_axis, '--', 'color', .8*[1 1 1]);
plot(switched.y_s{n}(end,1)*[1 1], y_axis, '--', 'color', .8*[1 1 1]);
xlabel('Time (s)'), ylabel('Step (V)'), xlim(x_axis), ylim(y_axis);
% cont = {'PD output',

%%
f2 = figure;

% set(gca,'windowstyle','normal', 'Position', [100, 100, 550, 550])
% set(gca, 'FontName', 'Times New Roman','FontSize',12)
fig_prop = {'linewidth', 1.5, 'markersize', 8};
subplot(3,1,[1, 2]);
plot(switched.y{n}(:,1),(switched.y{n}(:,2) - s_info.y_mean)/s_info.y_mod,...
    'color',.6*ones(1,3)); hold on
clear pConf; pConf = {'.', 'color', .4*[1 1 1], fig_prop{:};...
                      '.', 'color', .7*[1 1 1], fig_prop{:};...
                      'o', 'color', .7*[1 1 1], fig_prop{:}}; i=1;
% ax = gca; ax.ColorOrderIndex = 1;
for k = [2 6 7]
    t = switched.(eF{k}){n}(:,1);
    if k == 7, y = (switched.(eF{k}){n}(:,2) - s_info.x_mean)/s_info.x_mod;
    else, y = (switched.(eF{k}){n}(:,2) - s_info.y_mean)/s_info.y_mod;
    end
    plot(t, y, pConf{i,:}); i=i+1;
end
