%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATRIZ DE AUTOCORRELAÇÃO E VETOR DE CORRELAÇÃO CRUZADA %
%   Bruno Taglietti                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Para obter a matriz de autocorrelação Rx:
% Rx = mXcor(x,m)
%   x: vetor do sinal x
%   m: número de elementos da matriz
%
% Para obter vetor de correlação cruzada Pxd:
% Pxd = mXcor(x,d,m)
%   x: vetor do sinal x
%   d: vetor do sinal d
%   m: número de elementos do vetor Pxd
% 
% Para obter vetor de correlação cruzada
% aplicando atraso a d(n-tau)
% Pxd = mXcor(x,d,m,tau)
%   x: vetor do sinal x
%   d: vetor do sinal d
%   m: número de elementos do vetor Pxd
%   tau: atraso tau em d(n-tau)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Pxd = mXcor(varargin)
    x = varargin{1};
    M=length(x);
    switch nargin
        case 2
            m = varargin{2};
            X = zeros(m,M-m+1);
            for i = 1:m
                X(i,:) = x(i:end-(m-i));
            end
            Pxd = X*X'/M;
        case 3
            s = varargin{2};
            m = varargin{3};
            X = zeros(m,M-m+1);
            S = zeros(m,M-m+1);
            for i = 1:m
                X(i,:) = x(1:end-m+1);
                S(i,:) = s(i:end-(m-i));
            end
            Pxd = X*S'/M;
            Pxd = Pxd(1,:)';
        case 4
            s = varargin{2};
            m = varargin{3};
            tau = varargin{4};
            X = zeros(m,M-m-tau+1);
            S = zeros(m,M-m-tau+1);
            for i = 1:m
                X(i,:) = x(1+tau:end-m+1);
                S(i,:) = s(i:end-(m-i+tau));
            end
            Pxd = X*S'/M;
            Pxd = Pxd(1,:)';
        otherwise
            error('Número de argumentos de entrada inválidos')
    end
end