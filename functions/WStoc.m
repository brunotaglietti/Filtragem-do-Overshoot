%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOLUÇÃO DE WIENER ESTATÍSTICA
% Bruno Taglietti
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wo = WStoc(x,d,M) ou WStoc(x,d,M,alpha)
% 
% Wo:   Coeficientes do filtro FIR resultante
% x:    vetor distorcido ruidoso
% d:    vetor referência
% M:    número de coeficientes
% alpha:    atraso
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Wo = WStoc(x,d,M,varargin)
Rx = mXcor(x,M);
switch nargin
    case 3, Pxd = mXcor(x,d,M);
    case 4, Pxd = mXcor(x,d,M,varargin{1});
end
Wo = Rx\Pxd;
end