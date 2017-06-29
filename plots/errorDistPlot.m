function errorDistPlot(s_info, errors)
fprintf('Guard-Interval Analysis and plot.\n')
%%
eFields = fieldnames(errors{1})';
close all; figure;
errorDist = zeros(1,max(s_info.Samp_Cy));
for N = 1:length(errors)
    for f = 1:length(eFields)
        for k = 1:s_info.N_cycles
            errorDist(1:s_info.Samp_Cy(k)) = errorDist(1:s_info.Samp_Cy(k)) + errors{N}.(eFields{f}){k};
        end
        subplot(length(errors),length(eFields), (f + (N-1)*length(eFields)))
        bar(errorDist), title(eFields{f});
    end
end
%%

maxGI = 25; endcrop = 0;
M = zeros(1,maxGI+1);
eFalloc = eFields; for i=1:length(eFields), eFalloc{2,i} = M; end
GIerror = struct(eFalloc{:}); clear M eFalloc i;
%%
figure;
LGImin = 0; plotStyle = {'--o', 'linewidth',2; '-+','linewidth',1};
for N = 1:length(errors)
    for f = 1:length(eFields)
        for GI = 0:maxGI
            for k = 1:s_info.N_cycles
                GIerror.(eFields{f})(GI+1) = GIerror.(eFields{f})(GI+1) + ...
                    sum(errors{N}.(eFields{f}){k}(1+GI:end-endcrop));
            end
            GIerror.(eFields{f})(GI+1) = GIerror.(eFields{f})(GI+1)/...
            (sum(s_info.Samp_Cy)-GI*s_info.N_cycles);
        end
        LGIerror = log10(GIerror.(eFields{f}));
        if LGImin > min(LGIerror(LGIerror~=-Inf)), LGImin = min(LGIerror(LGIerror~=-Inf)); end
        LGIerror(LGIerror==-Inf) = -100;
        plot(0:maxGI,LGIerror,plotStyle{N,:}), hold on; ylim([LGImin -1]);
        xlabel('Guard-Interval'), ylabel('Log_{10} (BER)');
    end
    ax = gca; ax.ColorOrderIndex = 1;
end
eNormLeg = eFields; for N = 1:length(eFields), eNormLeg{N} = ['Norm ' eFields{N}]; end
content = {eFields, eNormLeg}; legend([content{:}]), grid on
end