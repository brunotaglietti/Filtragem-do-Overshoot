function rlsfigsave(name)
if ~exist('rls_results/', 'dir'), mkdir('rls_results/'); end
saveas(gcf,['rls_results/' name '.fig']);
print(['rls_results/' name '.eps'], '-depsc');
print(['rls_results/' name '.png'],'-dpng')
end