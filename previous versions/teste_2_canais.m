close all; % clear all; tic;
root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
addpath([root_dir 'MatLab/'], [root_dir 'chav-amo-SOA-prbs'], 'functions', 'plots');
clear root_dir;

SOA = 'CIP-L';
char_var = [1200 1200];
method = 'syncd/switch_fiber_test';
signal = test_file_import(SOA,char_var,method);

%%

wnd = (1:1000) + 19e6;
if ishandle(1), close(1); end; fig1 = figure(1);
signal.y(:,2) = signal.y(:,2) * max(signal.y(:,1))/max(signal.y(:,2));

tic;
while(toc<5)
    wnd = wnd + 10;
    plot(signal.t(wnd,1),signal.y(wnd,1),'b'), hold on
    plot(signal.t(wnd,2),signal.y(wnd,2),'r')
    xlim([signal.t(wnd(1),1), signal.t(wnd(end),1)]), drawnow;
end

%%
M = 100;    L = 1e5;
Rx = mXcor(signal.y(1:L,2),M);
Pxd = mXcor(signal.y(1:L,2), signal.y(1:L,1), M);
w = Rx\Pxd;

yw = filter(w,1,signal.y(1:L,2));

%%

wnd = 1:1e3;
if ishandle(2), close(2); end; fig2 = figure(2);
% set(0,'defaultlinelinewidth',1)
tic;
while(toc<5)
    wnd = wnd + 10;
    plot(signal.t(wnd,1), signal.y(wnd,1), 'b'), hold on;
    plot(signal.t(wnd,2), signal.y(wnd,2), 'r')
    plot(signal.t(wnd,2), yw(wnd), 'g')
    xlim([signal.t(wnd(1),1), signal.t(wnd(end),1)]), drawnow;
end
contents = {'Generator output', 'Photodetector output', 'Filter output'};
legend(contents), set(gca, 'FontName', 'Times New Roman','FontSize',12)
xlabel('Time (s)'), ylabel('Signals (V)')
if ishandle(3), close (3); end; fig3 = figure(3);
stem(w), title('Taps coefficients')