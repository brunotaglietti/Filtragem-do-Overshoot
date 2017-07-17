function [yout, regMSE, ber, errors] = regFilter(y_s, x_s)
%% Normalize signals
ys = (y_s(:,2) - mean(y_s(:,2)))/sqrt(mean(y_s(:,2).^2));
xs = (x_s(:,2) - mean(x_s(:,2)))/sqrt(mean(x_s(:,2).^2));
yout.y = ys; yout.ySl = sign(ys);
yout.x = xs; yout.xSl = sign(xs);
% stem(ys(1:100))
%%
M = 2; M2 = 10;
R = mXcor(ys, M); Pxd = mXcor(ys, xs, M);
R2 = mXcor(ys, M2); Pxd2 = mXcor(ys, xs, M2);
w = R\Pxd; w2 = R2\Pxd2;

yout.w = filter(w,1,ys);
yout.w2 = filter(w2,1,ys);
[~,~, yout.rls] = algRLS(ys, xs, w);
[~,~, yout.rls2] = algRLS(ys, xs, w2);

yout.e = (ys - xs).^2;  regMSE.s = mean(yout.e);
yout.ew = (yout.w - xs).^2; regMSE.w = mean(yout.ew);
yout.ew2 = (yout.w2 - xs).^2; regMSE.w2 = mean(yout.ew2);
yout.erls = (yout.rls - xs).^2; regMSE.rls = mean(yout.erls);
yout.erls2 = (yout.rls2 - xs).^2; regMSE.rls2 = mean(yout.erls2);

errors.s = (sign(ys) ~= sign(xs))';             ber.s = sum(errors.s)/length(ys);
errors.w = (sign(yout.w) ~= sign(xs))';         ber.w = sum(errors.w)/length(yout.w);
errors.w2 = (sign(yout.w2) ~= sign(xs))';       ber.w2 = sum(errors.w2)/length(yout.w2);
errors.rls = (sign(yout.rls) ~= sign(xs))';     ber.rls = sum(errors.rls)/length(yout.rls);
errors.rls2 = (sign(yout.rls2) ~= sign(xs))';   ber.rls2 = sum(errors.rls2)/length(yout.rls2);

end