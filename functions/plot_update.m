%% Atualiza��o das imagens
% As informa��es de entrada devem estar no formato: "objeto 1, dados 1,
% objeto 2, dados 2...".

function plot_update(handle,data)
for n = 1:2:nargin
%     handle = varargin{n};
%     data = varargin{n};
    if size(data,2) == 1
        set(handle,'YData',data)
    elseif size(data,2) == 2
        set(handle,'XData',data(:,1),'YData',data(:,2))
    else
        error('Informa��es de entrada inv�lidas')
    end
end