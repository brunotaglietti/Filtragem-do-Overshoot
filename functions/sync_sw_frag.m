%% Complemento da função sw_cycle
% Fragmenta os ciclos de chaveamento do sinal y em células individuais e atualiza as
% informações considerando o sinal completo

function [switched, s_info] = sync_sw_frag(signal)
total_l = length(signal.y(:,1));
crop = 6e4;     % Empiricamente encontrado com base no tempo de processamento
scrop.y = signal.y(1:crop,:);  scrop.t = signal.t(1:crop,:);
[switched, s_info] = sw_cycle(scrop);
for i = 2:floor(total_l/crop)
    slot = 1+(i-1)*crop:i*crop;
    scrop.y = signal.y(slot,:);
    scrop.t = signal.t(slot,:);
    [cur_sw, cur_info] = sw_cycle(scrop);
    switched.y = [switched.y; cur_sw.y]; switched.y_s = [switched.y_s; cur_sw.y_s];
    switched.x = [switched.x; cur_sw.x]; switched.x_s = [switched.x_s; cur_sw.x_s];
    switched.ys_slice = [switched.ys_slice; cur_sw.ys_slice];
    switched.xs_slice = [switched.xs_slice; cur_sw.xs_slice];
    s_info.Samp_Cy = [s_info.Samp_Cy; cur_info.Samp_Cy];
    s_info.N_cycles = [s_info.N_cycles; cur_info.N_cycles];
    s_info.y_mean = [s_info.y_mean; cur_info.y_mean];
    s_info.x_mean = [s_info.x_mean; cur_info.x_mean]; 
    s_info.y_mod = [s_info.y_mod; cur_info.y_mod];
    s_info.x_mod = [s_info.x_mod; cur_info.x_mod];
end
s_info.N_cycles = sum(s_info.N_cycles);
s_info.y_mean = mean(s_info.y_mean);
s_info.x_mean = mean(s_info.x_mean);
s_info.y_mod = mean(s_info.y_mod);
s_info.x_mod = mean(s_info.x_mod);
end