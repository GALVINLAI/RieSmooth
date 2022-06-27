function overview=RMC_mergefigs(ax,Name)
% plot six results in one figure


overview = figure;
for i=1:5
    ax_copy = copyobj(ax(i),overview);
    if i>=4
        subplot(2,3,i+0.5,ax_copy);
    else
        subplot(2,3,i,ax_copy);
    end
    lgd=legend;
    lgd.FontSize = 9;
    legend('Location','northeast');
end
overview.Position=[246 125 1510 846];
f = gcf;
exportgraphics(f,append(Name),'Resolution',300)
end