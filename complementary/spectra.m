close all
rootdir = 'E:\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L - 2017.07.20\OSA\';
names = dir(rootdir);
names = {names(~[names.isdir]).name};

filesdir = cell(2,length(names));
for k = 1:length(names), filesdir{1,k} = rootdir; filesdir{2,k} = names{k}; end

% SOA_output = [22, 20, 21, 26, 24, 25]; % without and with BPF
SOA_output = [22, 20, 21, 26];
SSMF = [29, 27, 28, 30];


hold on
for id = SOA_output
    spec = load([filesdir{:,id}]);
    plot(spec(:,1), spec(:,2),'linewidth',1)
%     title(strrep(names{id}(1:end-4), '_', ' '))
end
legend(strrep(names(SOA_output), '_', ' '))
[~,i] = max(spec(:,2));
lambda_c = spec(i,1);
span = 1e-9;
xlim(lambda_c - [span, -span]), ylim([-80 0])
set(gca,'fontsize', 12, 'FontName', 'Times New Roman')
xlabel('Wavelength (m)'), ylabel('Optical Power (dBm)')
%%
print -depsc '.\Org_Res\spectra\SSMF with and without BPF.eps'