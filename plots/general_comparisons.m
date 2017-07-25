% figure; 
% close all
load('./Results/BERxGI')

spans = {'SSMF', 'NZD 25 Km', 'NZD 50 Km', 'NZD 75 Km',...
    'NZD 25 Km with DC', 'NZD 50 Km with DC', 'NZD 75 Km with DC'};
biasses = {'80 mA', '100 mA', '120 mA'};
techs = {'step', 'pisic', 'misic'};
bitses = [2, 4, 8];
cmpr_var = spans;

T = 1;
mrkr = {'-+','-o','-*','-v','-x','-s','-d','-^','-.','->','-<','-p','-h'};

eF = 

% for k = [1 2 5 3 6 4 7]
% for k = [2 5 3 6]
% for k = 1:length(biasses)
for k = 1:3
    cmpr = BERxGI{1,1,3,k};
    plot(0:length(cmpr.w2)-1, cmpr.w2, mrkr{k},'linewidth',1.5), hold on;
    set(gca, 'YScale', 'log')
end
grid on; ylim([1e-5 .1]); xlim([0 7]);
xlabel('Guard-Interval (samples)'), ylabel('BER');
% title([techs{T} ' - 4']);
% biasses
% legend({'80 mA', '100 mA', '120 mA', '80 mA w/ Wiener', '100 mA w/ Wiener', '120 mA w/ Wiener'})

% spans
% content = spans([1, 2, 5, 3, 6, 4, 7]);
% content = {spans{[2 5 3 6]},spans{[2 5 3 6]}};
% legend(techs)
set(gca,'fontsize', 12, 'FontName', 'Times New Roman')
% print -depsc '.\Org_Res\spans - samples - step - 80ma.eps'