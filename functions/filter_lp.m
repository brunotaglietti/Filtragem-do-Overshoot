%Retorna o vetor referente a um FIR Lowpass

function [h,M] = filter_lp(wp,ws,Rp,As,type)

wt = ws-wp;
if(type=='Rec');
    M = ceil(1.8*pi/wt)+1;
    wd = (boxcar(M))';
elseif(type=='Bar');
    M = ceil(6.1*pi/wt)+1;
    wd = (bartlett(M))';
elseif(type=='Han');
    M = ceil(6.2*pi/wt)+1;
    wd = (hann(M))';
elseif(type=='Ham');
    M = ceil(6.6*pi/wt)+1;
    wd = (hamming(M))';
elseif(type=='Bla');
    M = ceil(11*pi/wt)+1;
    wd = (blackman(M))';
else(type=='Kay');
    M = ceil((As-7.95)/(2.285*wt)+1)+1;
    if(As>=50) beta = 0.1102*(As-8.7);
    elseif(As>=21) beta = 0.5842*(As-21)^0.4+0.07886*(As-21);
    end
    wd = (kaiser(M,beta))';
end

n = [0:1:M-1];
wc = (ws+wp)/2;
hd = wc/pi*sinc(wc*(n-(M-1)/2)/pi);
h = hd.*wd;

% [H,w] = freqz(h,[1],1000,'whole');
% H = (H(1:1:501))';
% w = (w(1:1:501))';
% mag = abs(H);
% db = 20*log10((mag+eps)/max(mag));
% pha = angle(H);
% 
% delta_w = 2*pi/1000;
% realRp = -(min(db(1:1:wp/delta_w+1)));
% realAs = -round(max(db(ws/delta_w+1:1:501)));

% M
% realRp
% realAs


% subplot(2,2,1);
% stem(n,hd,'black','filled','markersize',2);
% title('Resposta Ideal ao Impulso')
% axis([0 M-1 min(hd)-0.05 max(hd)+0.05]);
% xlabel('n');
% ylabel('hd(n)');
% 
% subplot(2,2,2);
% stem(n,wd,'black','filled','markersize',2);
% title('Função Janela')
% axis([0 M-1 0 1.1]);
% xlabel('n');
% ylabel('w(n)');
% 
% subplot(2,2,3);
% stem(n,h,'black','filled','markersize',2);
% title('Resposta Real ao Impulso')
% axis([0 M-1 min(h)-0.05 max(h)+0.05]);
% xlabel('n');
% ylabel('h(n)');
% 
% subplot(2,2,4);
% plot(w/pi,db,'black','LineWidth',2);
% title('Resposta em Magnitude em dB');
% axis([0 1 -100 10]);
% grid;
% set(gca,'XTickMode','manual','XTick',[0,wp/pi,ws/pi,1])
% set(gca,'YTickMode','manual','YTick',[-As,0])
% xlabel('w/pi');
% ylabel('dB');

end

