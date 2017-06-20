%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Algoritmo Recursive Least Squares (RLS)
% Bruno Taglietti
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% W = algRLS(x,d,M)
% [W, e, y] = algLMS(x,d,(M OU Wi),lambda,alpha,delta)
% W:    Coeficientes do filtro FIR resultante
% x:    vetor distorcido ruidoso
% d:    vetor referência
% M:    número de coeficientes
% Wi
% lambda:   fator de esquecimento
% alpha:    atraso
% delta:    coeficiente de iniciação
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [W, varargout] = algRLS(x,d,Mi,varargin)
T = length(x);
if size(Mi,1) ~= 1, Wi = Mi; M = size(Mi,1);
else M = Mi; Wi = zeros(M,1); end
switch nargin
    case 3
        lambda = 0.9;
        alpha = 0;
        delta = sum(x.^2)/T;
    case 4
        lambda = varargin{1};
        alpha = 0;
        delta = sum(x.^2)/T;
    case 5
        lambda = varargin{1};
        alpha = varargin{2};
        delta = sum(x.^2)/T;
    case 6
        lambda = varargin{1};
        alpha = varargin{2};
        delta = varargin{3};
    otherwise
        error('Número de argumentos de entrada inválidos')
end
X = zeros(M,1);
y = zeros(1,T-alpha);
e = zeros(1,T-alpha);
P = eye(M)/delta;
W = zeros(M,T-alpha+1);
W(:,1) = Wi;
for i = 1:alpha
    X = [x(i); X(1:end-1)];
end
for i = 1:T-alpha
    X = [x(i+alpha); X(1:end-1)];
    y(i) = X'*W(:,i);
    e(i) = d(i) - y(i);
    g = P*X/(lambda + X'*P*X);
    P = P/lambda - g*X'*P/lambda;
    W(:,i+1) = W(:,i) + g*e(i);
end
switch nargout
    case 2
        varargout{1} = e';
    case 3
        varargout{1} = e';
        varargout{2} = y';
end
end