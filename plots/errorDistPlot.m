function errorDistPlot(s_info, errors)
close all; fprintf('Guard-Interval Analysis and plot.\n')
eFields = fieldnames(errors)';
%%
errorDist = zeros(1,max(s_info.Samp_Cy));
for f = 1:length(eFields)
for k = 1:s_info.N_cycles
    errorDist(1:s_info.Samp_Cy(k)) = errorDist(1:s_info.Samp_Cy(k)) + errors.(eFields{f}){k};
end
subplot(1,length(eFields),f)
bar(errorDist), title(eFields{f})
end

%%

maxGI = 25; endcrop = 10;
M = zeros(1,maxGI+1);
eFalloc = eFields; for i=1:length(eFields), eFalloc{2,i} = M; end
GIerror = struct(eFalloc{:}); clear M eFalloc i;

figure;
for f = 1:length(eFields)
for GI = 0:maxGI
for k = 1:s_info.N_cycles
    GIerror.(eFields{f})(GI+1) = GIerror.(eFields{f})(GI+1) + sum(errors.(eFields{f}){k}(1+GI:end-endcrop));
end
GIerror.(eFields{f})(GI+1) = GIerror.(eFields{f})(GI+1)/(sum(s_info.Samp_Cy)-GI*s_info.N_cycles);
end
plot(0:maxGI,log10(GIerror.(eFields{f})),'-o'), hold on;
xlabel('Guard-Interval'), ylabel('Log_{10} (BER)'), %ylim([-1.6 -1]);
end
legend(eFields)
end