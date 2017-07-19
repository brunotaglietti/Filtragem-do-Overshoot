spans = {'SSMF', 'NZD_25', 'NZD_50', 'NZD_75',...
    'NZD_25_DC', 'NZD_50_DC', 'NZD_75_DC'};

for Fiber = 1:length(spans)

charinfo.SOA = 'CIP-L';                 % SOA
charinfo.span = spans{Fiber};           % Fiber setup
charinfo.sw_period = 2*100/12.5e9;      % Switching period
charinfo.fmod = 6.9994e9;               % Modulation frequency (symbols)
charinfo.pinpd = 'var';                 % Photodetector power
charinfo.pinsoa = -8;                   % SOA optical input power
charinfo.EDFA = 0.150;                  % EDFA Pump laser current
charinfo.modV = 1;                      % modulation amplitude
charinfo.cur = (0.080:0.020:0.120);     % SOA polarization biases
charinfo.deg = 1.2;                     % Switching step amplitude
charinfo.imp = 1.2;                     % Pre-impulse amplitude

cur = charinfo.cur; deg = charinfo.deg;
direc_root = ['E:\Projetos Colaborativos\chav-amo-SOA-prbs\',...
    charinfo.SOA, '\', charinfo.span, '\'];
charinfo.root = direc_root;

if ~exist('direc_root', 'dir'), mkdir(direc_root); end
save([direc_root 'charinfo.mat'],'charinfo');

strend = ['-mod' sprintf('%.0f',charinfo.modV*1e3) 'mV-',...
    'pinpd-' charinfo.pinpd,...
    '-pinsoa' num2str(charinfo.pinsoa) 'dbm'];

method = {'step-','pisic-','misic-','steady-'};
for k = 1:length(method)
for bits = [2, 4, 8]    
strcall = method{k};
imp = deg; tim = bits/12.5;
direc = [direc_root strcall sprintf('%i',bits) '\'];
if ~isempty(strfind(lower(strcall),'step')) || ~isempty(strfind(lower(strcall),'steady'))
    imp = 0; tim = 0; direc = [direc_root strcall(strcall~='-') '\'];
end
for i = 1:length(cur)
    if ~exist([direc 'dados/'], 'dir'), mkdir([direc 'dados/']); end
    if ~exist([direc 'figs/'], 'dir'), mkdir([direc 'figs/']); end
    for j = 1:length(tim)
       for m = 1:length(deg)
           aux1 = sprintf('i%1.3fA-t%1.2fns-deg%1.2fV-imp%1.2fV',cur(i),tim(j),deg(m),imp);
           file = fopen([direc 'dados\' strcall aux1 strend '.h5'],'w');
           file = fopen([direc 'figs\' strcall aux1 strend '.png'],'w');
       end
    end
end
fclose('all');
end
end

end