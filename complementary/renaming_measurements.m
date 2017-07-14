% renomeia o arquivo

% ERRADO
% misic-4
% misic-i0.060A-t0.32ns-deg0.00V-imp0.00V-mod500mV-pinpd-12dbm-pinsoa-9dbm

% CORRETO
% misic-2
% misic-i0.060A-t0.16ns-deg0.00V-imp0.00V-mod1000mV-pinpd-var-pinsoa-5dbm

% RESULTADO
% misic-i0.060A-t0.32ns-deg0.00V-imp0.00V-mod1000mV-pinpd-var-pinsoa-5dbm.h5

for soa_cur = 60:20:180
    root_dir = ['C:\Users\Bruno\Documents\Projetos Colaborativos\chav-amo-SOA-prbs\CIP-L\' ...
        'syncd\misic-4\dados\' sprintf('%imA',soa_cur) '\'];
    names = dir(root_dir);
    names = {names(~[names.isdir]).name};
    oldname = cell(1,length(names)); newname = oldname;
    
    for id = 1:length(names)
        oldname{id} = [root_dir names{id}];
        curname = names{id};
        if strcmp(curname(44),'5')
            correct_name = [curname(1:43) '1000' curname(47:end)];
        end
        if strcmp(curname(56),'1') && strcmp(curname(44),'5')
            correct_name = [correct_name(1:56) 'var' correct_name(62:end)];
            if strcmp(correct_name(68),'9')
                correct_name(68) = '5';
            end
        end
        newname{id} = [root_dir correct_name];
        movefile(oldname{id}, newname{id})
    end
end