%% Filtragem do sinal
% O sinal chaveado switched � filtrado nesta fun��o. As sa�das da fun��o s�o o sinal de
% sa�da do filtro, o Erro M�dio Quadr�tico (MSE) resultante e a taxa de erro (BER).

function [yout, sw_mse, ber, errors] = sw_filter(switched, s_info, filter_info)
fprintf('Filtering cycles. ')
M = 2; M2 = 4;
section = 20;
section_rls = 5;
if exist('rls_info','var')
    M = filter_info.M;
    M2 = filter_info.M2;
    section = filter_info.section;
    section_rls = filter_info.section_rls;
end
Rx = zeros(s_info.N_cycles,M); Pxd = Rx;
Rrls = Rx; Prls = Rx;
Rx2 = zeros(s_info.N_cycles,M2); Pxd2 = Rx2;
Rrls2 = Rx2; Prls2 = Rx2;
for n = 1:s_info.N_cycles
    ys = switched.y_s{n};       ys = (ys(:,2) - s_info.y_mean)/s_info.y_mod;
    xs = switched.xs_slice{n};  xs = (xs(:,2) - s_info.x_mean)/s_info.x_mod;
    if section > length(ys), section = length(ys); end;
    R = mXcor(ys(1:section), M);            Rx(n,:) = R(1,:);
    R2 = mXcor(ys(1:section), M2);          Rx2(n,:) = R2(1,:);
    Rrls_c = mXcor(ys(1:section_rls),M);    Rrls(n,:) = Rrls_c(1,:);
    Rrls2_c = mXcor(ys(1:section_rls),M2);  Rrls2(n,:) = Rrls2_c(1,:);
    Prls(n,:) = mXcor(ys(1:section_rls), xs(1:section_rls), M);
    Prls2(n,:) = mXcor(ys(1:section_rls), xs(1:section_rls), M2);
    Pxd(n,:) = mXcor(ys(1:section), xs(1:section), M);
    Pxd2(n,:) = mXcor(ys(1:section), xs(1:section), M2);
end
Rx = mean(Rx);          Pxd = mean(Pxd);
w = toeplitz(Rx)\Pxd';
Rx2 = mean(Rx2);        Pxd2 = mean(Pxd2);
w2 = toeplitz(Rx2)\Pxd2';
Rrls = mean(Rrls);      Prls = mean(Prls);
wrlsi = toeplitz(Rrls)\Prls';
Rrls2 = mean(Rrls2);    Prls2 = mean(Prls2);
wrlsi2 = toeplitz(Rrls2)\Prls2';

yw = zeros(s_info.N_cycles,section);
yw2 = yw;   yrls = yw;  yrls_i = yw;    yrls2 = yw;
me = zeros(s_info.N_cycles,1);
mew = me; mew2 = me; merls = me; merls_i = me; merls2 = me;
se = zeros(s_info.N_cycles,section);
sew = se; sew2 = se;    serls = se;   serls_i = se;     serls2 = se;
wrls = zeros(M,1); wrls(1) = 1;

bers = zeros(s_info.N_cycles,section); sections = zeros(s_info.N_cycles,1);
berw = bers; berw2 = bers; berrls = bers; berrls_i = bers; berrls2 = bers;
for n = 1:s_info.N_cycles
    ys = switched.y_s{n};
    ys = (ys(1:section,2) - s_info.y_mean)/s_info.y_mod;
    xs = switched.xs_slice{n};
    xs = (xs(1:section,2)' - s_info.x_mean)/s_info.x_mod;
    if section > length(ys), sections(n) = length(ys);
    else, sections(n) = section; end;
    
    yw(n,:) = filter(w,1,ys);
    yw2(n,:) = filter(w2,1,ys);
    
    [~, ~, yrls(n,:)] = algRLS(ys,xs,wrls);     % wrls = w_rls(:,end);
    [~, ~, yrls_i(n,:)] = algRLS_mod(ys, xs, wrlsi, inv(toeplitz(Rrls)));
    [~, ~, yrls2(n,:)] = algRLS(ys, xs, wrlsi2);
    
    se(n,:) = (ys' - xs).^2; me(n) = mean(se(n,:));
    sew(n,:) = (yw(n,:) - xs).^2; mew(n) = mean(sew(n,:));
    sew2(n,:) = (yw2(n,:) - xs).^2; mew2(n) = mean(sew2(n,:));
    serls(n,:) = (yrls(n,:) - xs).^2; merls(n) = mean(serls(n,:));
    serls_i(n,:) = (yrls_i(n,:) - xs).^2; merls_i(n) = mean(serls_i(n,:));
    serls2(n,:) = (yrls2(n,:) - xs).^2; merls2(n) = mean(serls2(n,:));
    
    bers(n,:) = sign(ys') ~= sign(xs);
    berw(n,:) = sign(yw(n,:)) ~= sign(xs);
    berw2(n,:) = sign(yw2(n,:)) ~= sign(xs);
    berrls(n,:) = sign(yrls(n,:)) ~= sign(xs);
    berrls_i(n,:) = sign(yrls_i(n,:)) ~= sign(xs);
    berrls2(n,:) = sign(yrls2(n,:)) ~= sign(xs);
end
yout.w = yw;
yout.w2 = yw2;
yout.rls = yrls;
yout.rls_i = yrls_i;
yout.rls2 = yrls2;
yout.e = se;
yout.ew = sew;
yout.ew2 = sew2;
yout.erls = serls;
yout.erls_i = serls_i;
yout.erls2 = serls2;

sw_mse.s = mean(me);
sw_mse.w = mean(mew);
sw_mse.w2 = mean(mew2);
sw_mse.rls = mean(merls);
sw_mse.rls_i = mean(merls_i);
sw_mse.rls2 = mean(merls2);

errors.s = bers;
errors.w = berw;
errors.w2 = berw2;
errors.rls = berrls;
errors.rls_i = berrls_i;
errors.rls2 = berrls2;

ber.s = sum(bers(:))/sum(sections(:));
ber.w = sum(berw(:))/sum(sections(:));
ber.w2 = sum(berw2(:))/sum(sections(:));
ber.rls = sum(berrls(:))/sum(sections(:));
ber.rls_i = sum(berrls_i(:))/sum(sections(:));
ber.rls2 = sum(berrls2(:))/sum(sections(:));

end