function BERxGI = errorDistPlot(s_info, errors, pTitle)
fprintf('Guard-Interval Analysis and plot.\n')
if length(errors) == 1,  eFields = fieldnames(errors)';
else, eFields = fieldnames(errors{1})'; end

%%
% if exist('pTitle','var'), figure('name', pTitle);
% else figure; end
% errorDist = zeros(1,max(s_info.Samp_Cy));
% for N = 1:length(errors)
%     if length(errors)>1, cE = errors{N}; else, cE = errors; end
%     for f = 1:length(eFields)
%         for k = 1:s_info.N_cycles
%             curL = length(cE.(eFields{f}){k});
%             errorDist(1:curL) = errorDist(1:curL) + cE.(eFields{f}){k};
%         end
%         subplot(length(errors),length(eFields), (f + (N-1)*length(eFields)))
%         bar(errorDist), title(eFields{f});
%     end
% end
%%
maxGI = 25; endcrop = 5;
M = zeros(1,maxGI+1);
eFalloc = eFields; for i=1:length(eFields), eFalloc{2,i} = M; end
BERxGI = struct(eFalloc{:}); clear M eFalloc i;
figure;
LGImin = 0; plotStyle = {'-o', 'linewidth',2; '-+','linewidth',1};
for N = 1:length(errors)
    if length(errors)>1, cE = errors{N}; else, cE = errors; end
    for f = 1:length(eFields)
        for GI = 0:maxGI
            for k = 1:s_info.N_cycles
                BERxGI.(eFields{f})(GI+1) = BERxGI.(eFields{f})(GI+1) + ...
                    sum(cE.(eFields{f}){k}(1+GI:end-endcrop));
            end
            BERxGI.(eFields{f})(GI+1) = BERxGI.(eFields{f})(GI+1)/...
            (sum(s_info.Samp_Cy)-GI*s_info.N_cycles);
        end
        LGIerror = BERxGI.(eFields{f});
        if LGImin > min(LGIerror(LGIerror~=0)), LGImin = min(LGIerror(LGIerror~=-Inf)); end
%         LGIerror(LGIerror==-Inf) = -100;
        plot(0:maxGI,LGIerror,plotStyle{N,:}), hold on; %ylim([LGImin -1]);
        xlabel('Guard-Interval'), ylabel('BER'); set(gca, 'YScale', 'log')
        if exist('pTitle','var'), title(upper(pTitle)); end
    end
    ax = gca; ax.ColorOrderIndex = 1;
end
if length(errors)>1
eNormLeg = eFields; for N = 1:length(eFields), eNormLeg{N} = ['Norm ' eFields{N}]; end
content = {eFields, eNormLeg}; legend([content{:}]), grid on
else, legend(eFields), grid on
end

end