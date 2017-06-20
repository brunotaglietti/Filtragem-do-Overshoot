%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Algoritmo Least Mean Square (LMS)
% Bruno Taglietti
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% W = algLMS(x,d,M) algLMS(x,d,M,mu,alpha)
% W:    Coeficientes do filtro FIR resultante
% x:    vetor distorcido ruidoso
% d:    vetor referência
% M:    número de coeficientes
% mu:   tamanho do passo
% alpha:    atraso
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [W, varargout] = algLMS(x,d,M,varargin)
T = length(x);
switch nargin
    case 3
        mu = 0.01;
        alpha = 0;
    case 4
        mu = varargin{1};
        alpha = 0;
    case 5
        mu = varargin{1};
        alpha = varargin{2};
end
X = zeros(M,1);
W = zeros(M,T+1);
y = zeros(1,T);
e = zeros(1,T);
for i = 1:alpha
    X = [x(i); X(1:end-1)];
end
for i = 1:T-alpha
    X = [x(i+alpha); X(1:end-1)];
    y(i) = W(:,i)'*X;
    e(i) = d(i) - y(i);
    W(:,i+1) = W(:,i) + mu*X*e(i);
end
switch nargout
    case 2
        varargout{1} = e;
    case 3
        varargout{1} = e;
        varargout{2} = y;
end
end