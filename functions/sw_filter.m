%% Filtragem do sinal
% O sinal chaveado switched é filtrado nesta função. As saídas da função são o sinal de
% saída do filtro, o Erro Médio Quadrático (MSE) resultante e a taxa de erro (BER).

function [yout, sw_mse, ber, errors] = sw_filter(switched, s_info, filter_info)
fprintf('Filtering cycles. ')
%%
M = 2; M2 = 4;
if exist('rls_info','var')
    M = filter_info.M;
    M2 = filter_info.M2;
end
Rx = zeros(s_info.N_cycles,M); Pxd = Rx;
% Rrls = Rx; Prls = Rx;
Rx2 = zeros(s_info.N_cycles,M2); Pxd2 = Rx2;
% Rrls2 = Rx2; Prls2 = Rx2;
for n = 1:s_info.N_cycles
    ys = switched.y_s{n};       ys = (ys(:,2) - s_info.y_mean)/s_info.y_mod;
    xs = switched.xs_slice{n};  xs = (xs(:,2) - s_info.x_mean)/s_info.x_mod;
    R = mXcor(ys, M);           Rx(n,:) = R(1,:);
    R2 = mXcor(ys, M2);         Rx2(n,:) = R2(1,:);
%     Rrls_c = mXcor(ys,M);    Rrls(n,:) = Rrls_c(1,:);
%     Rrls2_c = mXcor(ys,M2);  Rrls2(n,:) = Rrls2_c(1,:);
%     Prls(n,:) = mXcor(ys, xs, M);
%     Prls2(n,:) = mXcor(ys, xs, M2);
    Pxd(n,:) = mXcor(ys, xs, M);
    Pxd2(n,:) = mXcor(ys, xs, M2);
end
Rx = mean(Rx); Pxd = mean(Pxd); w = toeplitz(Rx)\Pxd';
Rx2 = mean(Rx2); Pxd2 = mean(Pxd2); w2 = toeplitz(Rx2)\Pxd2';
% Rrls = mean(Rrls);      Prls = mean(Prls);
% wrlsi = toeplitz(Rrls)\Prls';
% Rrls2 = mean(Rrls2);    Prls2 = mean(Prls2);
% wrlsi2 = toeplitz(Rrls2)\Prls2';

yw = cell(s_info.N_cycles,1);
yw2 = yw;   yrls = yw;  yrls_i = yw;    yrls2 = yw;
me = zeros(s_info.N_cycles,1);
mew = me; mew2 = me; merls = me; merls2 = me; %merls_i = me;
se = cell(s_info.N_cycles,1);
sew = se; sew2 = se;    serls = se; serls2 = se; %serls_i = se;
% wrls = zeros(M,1); wrls(1) = 1;
%%
bers = cell(s_info.N_cycles,1); sections = zeros(s_info.N_cycles,1);
berw = bers; berw2 = bers; berrls = bers; berrls2 = bers; %berrls_i = bers;
for n = 1:s_info.N_cycles
    ys = switched.y_s{n};
    ys = (ys(:,2) - s_info.y_mean)/s_info.y_mod;
    xs = switched.xs_slice{n};
    xs = (xs(:,2) - s_info.x_mean)/s_info.x_mod;
    sections(n) = length(ys);
    
    yw{n} = filter(w,1,ys);
    yw2{n} = filter(w2,1,ys);
    
    [~, ~, yrls{n}] = algRLS(ys,xs,w);     % wrls = w_rls(:,end);
    [~, ~, yrls2{n}] = algRLS(ys, xs, w2);
%     [~, ~, yrls_i{n}] = algRLS_mod(ys, xs, wrlsi, inv(toeplitz(Rx)));
    
    se{n} = (ys - xs).^2; me(n) = mean(se{n});
    sew{n} = (yw{n} - xs).^2; mew(n) = mean(sew{n});
    sew2{n} = (yw2{n} - xs).^2; mew2(n) = mean(sew2{n});
    serls{n} = (yrls{n} - xs).^2; merls(n) = mean(serls{n});
    serls2{n} = (yrls2{n} - xs).^2; merls2(n) = mean(serls2{n});
%     serls_i{n} = (yrls_i{n} - xs).^2; merls_i(n) = mean(serls_i{n});
    
    bers{n} = (sign(ys) ~= sign(xs))';
    berw{n} = (sign(yw{n}) ~= sign(xs))';
    berw2{n} = (sign(yw2{n}) ~= sign(xs))';
    berrls{n} = (sign(yrls{n}) ~= sign(xs))';
    berrls2{n} = (sign(yrls2{n}) ~= sign(xs))';
%     berrls_i{n} = sign(yrls_i{n}) ~= sign(xs);
end
yout.w = yw;
yout.w2 = yw2;
yout.rls = yrls;
% yout.rls_i = yrls_i;
yout.rls2 = yrls2;
yout.e = se;
yout.ew = sew;
yout.ew2 = sew2;
yout.erls = serls;
yout.erls2 = serls2;
% yout.erls_i = serls_i;

sw_mse.s = mean(me);
sw_mse.w = mean(mew);
sw_mse.w2 = mean(mew2);
sw_mse.rls = mean(merls);
sw_mse.rls2 = mean(merls2);
% sw_mse.rls_i = mean(merls_i);

errors.s = bers;
errors.w = berw;
errors.w2 = berw2;
errors.rls = berrls;
errors.rls2 = berrls2;
% errors.rls_i = berrls_i;

ber.s = sum([bers{:}])/sum(sections(:));
ber.w = sum([berw{:}])/sum(sections(:));
ber.w2 = sum([berw2{:}])/sum(sections(:));
ber.rls = sum([berrls{:}])/sum(sections(:));
ber.rls2 = sum([berrls2{:}])/sum(sections(:));
% ber.rls_i = sum([berrls_i{:}])/sum(sections(:));
end