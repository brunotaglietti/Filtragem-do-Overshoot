% figure; 
close all
% load('./Results/BERxGI')
load('BERxGI');

spans = {'SSMF', 'NZD 25 Km', 'NZD 50 Km', 'NZD 75 Km',...
    'NZD 25 Km with DC', 'NZD 50 Km with DC', 'NZD 75 Km with DC'};
biasses = {'80 mA', '100 mA', '120 mA'};
techs = {'step', 'pisic', 'misic'};
bitses = [2, 4, 8];
cmpr_var = spans;

T = 1;
mrkr = {'-+','-o','-*','-v','-x','-s','-d','-^','-.','->','-<','-p','-h'};

cmpr = BERxGI{1,1,1,1};     % comparison
eF = fieldnames(cmpr);

for k = 1:3
    plot(0:length(cmpr.(eF{k}))-1,cmpr.(eF{k}), mrkr{k},'linewidth',1.5); hold on; grid on;
end
set(gca, 'YScale', 'log')

grid on; ylim([1e-4 .07]); xlim([0 4]);
xlabel('Guard-Interval (samples)'), ylabel('BER');
set(gca,'fontsize', 12, 'FontName', 'Times New Roman')
legend({'No Filter', 'Wiener (2 taps)', 'Wiener (4 taps)'},'location', 'southwest')