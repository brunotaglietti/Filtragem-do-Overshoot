% BERxGI{S,ib,T+1,ibits}
addpath('plots')
set(groot,'defaultLineLineWidth',2.0,...
    'defaultAxesTickLabelInterpreter','latex',...
    'defaultLegendInterpreter','latex',...
    'defaultAxesFontSize',14,...
    'defaultTextInterpreter','latex');
close all
load('./All Results/BERxGI')

spans = {'SSMF', 'NZD 25 km', 'NZD 50 km', 'NZD 75 km',...
    'NZD 25 km w/ DC', 'NZD 50 km w/ DC', 'NZD 75 km w/ DC'};
biasses = {'80 mA', '100 mA', '120 mA'};
techs = {'step', 'pisic', 'misic'};
bitses = [2, 4, 8];
mrkr = {'-+','-o','-*','-v','-x','-s','-d','-^','-.','->','-<','-p','-h'};
%% spans

kspan = [1 2 5 3 6];

for n = 1:length(kspan), k = kspan(n);
    cmpr = BERxGI{k,1,1,1};
    h1(n) = plot(0:length(cmpr.s)-1,cmpr.s,mrkr{k},'linewidth',1.5); hold on; grid on;
    h = gca; h.ColorOrderIndex = h.ColorOrderIndex-1;
    h2(n) = plot(0:length(cmpr.rls)-1,cmpr.rls,'--','linewidth',1.5);
end
set(gca, 'YScale', 'log')

ylim([1e-4 .07]); xlim([0 8]);
set(gca,'Xtick',0:8);
xlabel('Guard-Time Interval'), ylabel('BER');

leg1 = legend(h1,spans{kspan},'location', 'southwest');
set(leg1,'color','none','box','off');

rlsfigsave('spans');
%% Bias
close all

for k = 1:3
    cmpr = BERxGI{1,k,1,1};
    g1(k) = plot(0:length(cmpr.s)-1,cmpr.s,mrkr{k},'linewidth',1.5); hold on; grid on;
    h = gca; h.ColorOrderIndex = h.ColorOrderIndex-1;
    g2(k) = plot(0:length(cmpr.rls)-1,cmpr.rls,'--','linewidth',1.5);
end
set(gca, 'YScale','log');
ylim([1e-4 .07]); xlim([0 8]);
set(gca,'Xtick',0:8);
xlabel('Guard-Time Interval'), ylabel('BER');
leg2 = legend(g1,{'80 mA','100 mA','120 mA'});
set(leg2,'color','none','box','off');
rlsfigsave('biasses');
%% Techs
close all
for k = 1:3
    cmpr = BERxGI{1,1,k,1};
    g1(k) = plot(0:length(cmpr.s)-1,cmpr.s,mrkr{k},'linewidth',1.5); hold on; grid on;
    h = gca; h.ColorOrderIndex = h.ColorOrderIndex-1;
    g2(k) = plot(0:length(cmpr.rls)-1,cmpr.rls,'--','linewidth',1.5);
end
set(gca, 'YScale','log');
ylim([1e-4 .07]); xlim([0 8]);
set(gca,'Xtick',0:8);
xlabel('Guard-Time Interval'), ylabel('BER');
leg3 = legend(g1,{'Step', 'PISIC', 'MISIC'});
set(leg3,'color','none','box','off');
rlsfigsave('techs');
%% Impulse
close all
for k = 1:3
    cmpr = BERxGI{1,1,3,k};
    g1(k) = plot(0:length(cmpr.s)-1,cmpr.s,mrkr{k},'linewidth',1.5); hold on; grid on;
    h = gca; h.ColorOrderIndex = h.ColorOrderIndex-1;
    g2(k) = plot(0:length(cmpr.rls)-1,cmpr.rls,'--','linewidth',1.5);
end
set(gca, 'YScale','log');
ylim([1e-4 .07]); xlim([0 8]);
set(gca,'Xtick',0:8);
xlabel('Guard-Time Interval'), ylabel('BER');
leg3 = legend(g1,{'160 ps', '320 ps', '640 ps'});
set(leg3,'color','none','box','off');
rlsfigsave('impulses');